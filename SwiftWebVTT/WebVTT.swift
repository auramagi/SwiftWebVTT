public struct WebVTT {
    public struct Cue {
        public let timing: Timing
        public let contents: Node
    }
    
    /// Native timing in WebVTT. Measured in milliseconds.
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
        
        public var children: [Node] = []
        
        internal init(type: NodeType, classes: [String] = [], annotation: String? = nil) {
            self.type = type
            self.classes = classes
            self.annotation = annotation
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
