import Foundation

public struct HTMLCharacterReferences {
    /// Entity names for character substitution.
    /// - Example: ['gt': '>'], ['amp': '&']
    struct ReferenceNamed: Codepoints, Decodable {
        typealias Index = String
        
        let index: String
        let codepoints: [Int]
    }
    
    /// Substitutes for unwanted unicode codepoints in the resulting conversion.
    /// - Example: [0: 65533]
    struct ReferenceSubstitute: Codepoints, Decodable {
        typealias Index = Int
        
        let index: Int
        let codepoints: [Int]
    }
    
    let named: [ReferenceNamed.Index: ReferenceNamed]
    let substitute: [ReferenceSubstitute.Index: ReferenceSubstitute]
    
    // Named references are from HTML 5.1 2nd Edition: §8.5. Named character references
    // https://www.w3.org/TR/html51/syntax.html#named-character-references
    //
    // Substitutes are from HTML 5.1 2nd Edition: §8.2.4.69. Tokenizing character references
    // https://www.w3.org/TR/html51/syntax.html#consume-a-character-reference
    //
    /// Character references defined in HTML 5.1 standard
    public static func standard() -> HTMLCharacterReferences {
        return HTMLCharacterReferences(
            named: ReferenceNamed.file("references_named"),
            substitute: ReferenceSubstitute.file("references_substitutes")
        )
    }
    
    func string(reference number: Int) -> String? {
        if let substitute = self.substitute[number] { return substitute.string }
        if (number >= 0xD800 && number <= 0xDFFF) || number > 0x10FFFF { return "\u{FFFD}" }
        guard let scalar = UnicodeScalar(number) else { return "\u{FFFD}" }
        return String(scalar)
    }
    
    func string(reference name: String) -> String? {
        return named[name]?.string
    }
}

// MARK: - Loading entity definitions from file

internal protocol Codepoints: Decodable {
    associatedtype Index: Hashable
    
    var index: Index { get }
    var codepoints: [Int] { get }
    
    static func file(_ filename: String) -> [Index: Self]
}

internal extension Codepoints {
    var string: String {
        var string = ""
        codepoints
            .compactMap { UnicodeScalar($0) }
            .map { Character($0) }
            .forEach { string.append($0) }
        return string
    }
    
    static func file(_ filename: String) -> [Index: Self] {
        var returnValue: [Index: Self] = [:]
        try? loadJSONArray(filename: filename)
            .forEach { returnValue[$0.index] = $0 }
        return returnValue
    }
}

fileprivate extension Decodable {
    static func loadJSONArray(filename: String) throws -> [Self] {
        let bundle = Bundle(for: WebVTTParser.self)
        let url = bundle.url(forResource: filename, withExtension: "json")!
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Self].self, from: data)
    }
}

// MARK: - Decoding entities

internal extension CustomScanner {
    func handleCharacterReference(references: HTMLCharacterReferences, startSequence: String = "&", allowedCharacter: Character? = nil) -> String {
        let startLocation = scanLocation
        let replacement = self.consumeCharacterReference(references: references, allowedCharacter: allowedCharacter)
        if replacement == nil { scanLocation = startLocation }
        return replacement ?? startSequence
    }
    
    private func consumeCharacterReference(references: HTMLCharacterReferences, allowedCharacter: Character? = nil) -> String? {
        guard let c = peekCharacter() else { return nil }
        if c == allowedCharacter { return nil }
        switch c {
        case "\u{0009}", "\u{000A}", "\u{000C}", "\u{0020}", "\u{003C}", "\u{0026}":
            return nil
        case "#":
            skip(1)
            let isHex = consumeHexEntityStartingSequence()
            guard
                let number = scanInt(hexadecimal: isHex),
                scan(1) == ";"
                else { return nil }
            return references.string(reference: number)
        default:
            guard
                let name = scanUpToCharacters(from: CharacterSet(charactersIn: ";")),
                scan(1) == ";"
                else { return nil }
            return references.string(reference: name)
        }
    }
    
    private func consumeHexEntityStartingSequence() -> Bool {
        let startLocation = scanLocation
        let c = scanCharacter()
        let isHex = c == "x" || c == "X"
        if !isHex { scanLocation = startLocation }
        return isHex
    }
}

public extension String {
    func decodingHTMLEntities() -> String {
        let references = HTMLCharacterReferences.standard()
        var result = ""
        
        let scanner = CustomScanner(string: self)
        let startingCharacter = "&"
        let set = CharacterSet(charactersIn: startingCharacter)
        
        while !scanner.isAtEnd {
            let data = scanner.scanUpToCharacters(from: set)
            result += data ?? ""
            if scanner.scan(1) == startingCharacter {
                result += scanner.handleCharacterReference(references: references, startSequence: startingCharacter)
            }
        }
        
        return result
    }
}
