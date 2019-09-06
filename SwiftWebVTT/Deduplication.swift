import Foundation

public extension WebVTT {
    /// Filter out duplicated cues.
    ///
    /// Mainly for YouTube ASR captions.
    func deduplicated() -> WebVTT {
        var filteredCues: [WebVTT.Cue] = []
        var shownLines: [Substring] = []
        var lastEnd: Int = 0
        for cue in cues {
            let isConsecutive = lastEnd == cue.timing.start
            lastEnd = cue.timing.end
            let lines: [Substring] = cue.text.split(separator: "\n")
            var ignored = lines
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            if isConsecutive {
                for i in 0..<lines.count where !ignored[i] {
                    let line = lines[i]
                    ignored[i] = shownLines.item(at: i) == line || shownLines.item(at: i+1) == line
                }
            }
            let text = zip(lines, ignored)
                .compactMap { (line, isIgnored) in return isIgnored ? nil : line }
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .joined(separator: "\n")
            guard !text.isEmpty else { continue }
            shownLines = lines
            filteredCues.append(WebVTT.Cue(timing: cue.timing, contents: WebVTT.Cue.Node(type: .text(text))))
        }
        return WebVTT(cues: filteredCues)
    }
}

//func x(_ cue: WebVTT.Cue, prev: WebVTT.Cue) -> WebVTT.Cue {
//
//}

public extension WebVTT.Cue.Node {
    func splitChildrenInLines() -> [[WebVTT.Cue.Node]] {
        var result: [[WebVTT.Cue.Node]] = []
        var buffer: [WebVTT.Cue.Node] = []
        
        for node in children {
            switch node.type {
            case .text(let text):
                text.components(separatedBy: .newlines)
                    .enumerated()
                    .forEach { i, line in
                        if i > 0 {
                            result.append(buffer)
                            buffer = []
                        }
                        if !line.isEmpty {
                            let node = WebVTT.Cue.Node(type: .text(line))
                            buffer.append(node)
                        }
                    }
            default: buffer.append(node)
            }
        }
        if !buffer.isEmpty {
            result.append(buffer)
        }
        
        return result
    }
}
