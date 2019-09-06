public struct WebVTT {
    public struct Cue {
        public let timing: Timing
        public let contents: Node
    }
    
    /// Cue timings in milliseconds. Stored as integers for precision.
    public struct Timing {
        public let start: Int
        public let end: Int
    }
    
    public let cues: [Cue]
    
    public init(cues: [Cue]) {
        self.cues = cues
    }
}

// MARK: Tree structure

public extension WebVTT.Cue {
    class Node {
        public let type: NodeType
        
        public let classes: [String]
        public let annotation: String?
        
        public var children: [Node]
        
        public init(type: NodeType, classes: [String] = [], annotation: String? = nil, children: [Node] = []) {
            self.type = type
            self.classes = classes
            self.annotation = annotation
            self.children = children
        }
    }
    
    enum NodeType: Equatable {
        // Root node
        case root
        
        // Internal nodes
        case `class`
        case italic
        case bold
        case underline
        case ruby
        case rubyText
        case voice
        case language
        
        // Leaves
        case text(String)
        case timestamp(String)
    }
}

// MARK: - Convenience properties

public extension WebVTT.Timing {
    var duration: Int { return end - start }
}

// Converted times
public extension WebVTT.Cue {
    var timeStart: TimeInterval { return TimeInterval(timing.start) / 1000 }
    var timeEnd: TimeInterval { return TimeInterval(timing.end) / 1000 }
    var duration: TimeInterval { return TimeInterval(timing.duration) / 1000 }
}

// Cue text convesion
public extension WebVTT.Cue {
    var text: String {
        return contents.string()
    }
    
    func attributedText(baseFont: UIFont) -> NSAttributedString {
        return contents.attributedString(font: baseFont)
    }
}

// MARK: - Debug string

extension WebVTT.Cue.NodeType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .root: return "_"
        case .class: return "c"
        case .italic: return "i"
        case .bold: return "b"
        case .underline: return "u"
        case .ruby: return "ruby"
        case .rubyText: return "rt"
        case .voice: return "v"
        case .language: return "lang"
        case .text(let text): return text.debugDescription
        case .timestamp(let timestamp): return "\\\(timestamp)\\"
        }
    }
}

extension WebVTT.Cue.Node: CustomDebugStringConvertible {
    public var debugDescription: String {
        var result = ([type.debugDescription] + classes).joined(separator: ".")
        
        if let annotation = annotation {
            result.append("(\(annotation.debugDescription))")
        }
        if !children.isEmpty {
            result.append(children.debugDescription)
        }
        
        return result
    }
}
