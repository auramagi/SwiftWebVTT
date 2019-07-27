public struct WebVTT {
    public struct Cue {
        public let timing: Timing
        public let text: String
    }
    
    // Native timing in WebVTT. Measured in milliseconds.
    public struct Timing {
        public let start: Int
        public let end: Int
    }
    
    public let cues: [Cue]
    
    public init(cues: [Cue]) {
        self.cues = cues
    }
}

public extension WebVTT.Timing {
    var duration: Int { return end - start }
}

// Converted times for convenience
public extension WebVTT.Cue {
    var timeStart: TimeInterval { return TimeInterval(timing.start) / 1000 }
    var timeEnd: TimeInterval { return TimeInterval(timing.end) / 1000 }
    var duration: TimeInterval { return TimeInterval(timing.duration) / 1000 }
}
