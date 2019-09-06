import Foundation

/// Building a tree from CueTextParser tokens
class CueTextTreeParser {
    let root = WebVTT.Cue.Node(type: .root)
    
    private var stack: [WebVTT.Cue.Node] = []
    private var current: WebVTT.Cue.Node { return stack.last ?? root }
    
    func parse(_ tokens: [CueTextParser.Token]) -> WebVTT.Cue.Node {
        for token in tokens {
            switch token {
            case .text(let text):
                attach(.text(text))
            case .timestamp(let timestamp):
                attach(.timestamp(timestamp))
            case .tagStart(let tag, let classes, let annotation):
                guard let type = WebVTT.Cue.NodeType(tag) else { break }
                let node = WebVTT.Cue.Node(type: type, classes: classes, annotation: annotation)
                attach(node)
            case .tagEnd(let tag):
                close(tag)
            }
        }
        stack = []
        return root
    }
    
    private func attach(_ type: WebVTT.Cue.NodeType) {
        attach(WebVTT.Cue.Node(type: type))
    }
    
    private func attach(_ node: WebVTT.Cue.Node) {
        if !node.type.isNestable,
            let i = stack.firstIndex(where: { $0.type == node.type }) {
            stack.removeLast(stack.count - i)
        }
        current.children.append(node)
        guard !node.type.isLeaf else { return }
        stack.append(node)
    }
    
    private func close(_ tag: String) {
        guard let type = WebVTT.Cue.NodeType(tag) else { return }
        if (current.type == type) || (type == .ruby && current.type == .rubyText) {
            stack.removeLast()
        }
    }
}

// MARK: - Plain text conversion
public extension WebVTT.Cue.Node {
    static func voiceAnnotation(_ annotation: String?) -> String {
        return annotation == nil ? "" : "\(annotation!): "
    }
    
    static func rubyText(_ text: String) -> String {
        return text.isEmpty ? "" : "(\(text))"
    }
    
    func string() -> String {
        var result = ""
        switch type {
        case .text(let text): result += text
        case .voice: result += WebVTT.Cue.Node.voiceAnnotation(annotation)
        case .rubyText: return WebVTT.Cue.Node.rubyText(childrenText)
        case .timestamp(_):
            break
        default: break
        }
        result += childrenText
        return result
    }
    
    private var childrenText: String {
        return children.map({ $0.string() }).joined()
    }
}

// MARK: - Attributed string conversion

public extension WebVTT.Cue.Node {
    func attributedString(font: UIFont) -> NSAttributedString {
        let result = NSMutableAttributedString(string: "")
        switch type {
        case .text(let text):
            let attributes = font.attributes(addingTraits: [])
            result.append(NSAttributedString(string: text, attributes: attributes))
        case .voice:
            let text = WebVTT.Cue.Node.voiceAnnotation(annotation)
            let attributes = font.attributes(addingTraits: [.traitBold])
            result.append(NSAttributedString(string: text, attributes: attributes))
        case .rubyText:
            let attributes = font.attributes(addingTraits: [])
            return NSAttributedString(string: WebVTT.Cue.Node.rubyText(childrenText), attributes: attributes)
        case .timestamp(_):
            break
        default: break
        }
        
        children.forEach { result.append($0.attributedString(font: font)) }
        
        result.addAttributes(attributes(font: font), range: NSRange(location: 0, length: result.length))
        return result
    }
    
    func attributes(font: UIFont) -> [NSAttributedString.Key: Any] {
        switch type {
        case .italic:
            return font.attributes(addingTraits: [.traitItalic])
        case .bold:
            return font.attributes(addingTraits: [.traitBold])
        case .underline:
            return [.underlineStyle: NSUnderlineStyle.single.rawValue]
        case .language:
            return [:]
        case .class:
            return [:]
        default: return [:]
        }
    }
}

fileprivate extension WebVTT.Cue.NodeType {
    // only internal nodes
    init?(_ tag: String) {
        switch tag {
        case "c": self = .class
        case "i": self = .italic
        case "b": self = .bold
        case "u": self = .underline
        case "ruby": self = .ruby
        case "rt": self = .rubyText
        case "v": self = .voice
        case "lang": self = .language
        default: return nil
        }
    }
    
    var isLeaf: Bool {
        switch self {
        case .text(_), .timestamp(_): return true
        default: return false
        }
    }
    
    var isNestable: Bool {
        switch self {
        case .class: return true
        default: return false
        }
    }
}

fileprivate extension UIFont {
    func attributes(addingTraits addedTraits: UIFontDescriptor.SymbolicTraits) -> [NSAttributedString.Key: Any] {
        let traits = fontDescriptor.symbolicTraits.union(addedTraits)
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return [:] }
        return [.font: UIFont(descriptor: descriptor, size: descriptor.pointSize)]
    }
}
