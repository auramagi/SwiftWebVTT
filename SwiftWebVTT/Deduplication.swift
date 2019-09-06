// Remove empty cues, empty lines, and duplicate lines if they follow some rules.
// See Deduplication.md for details.

import Foundation

public extension WebVTT {
    /// Filter out duplicated cues.
    ///
    /// Mainly for YouTube ASR captions.
    func deduplicated() -> WebVTT {
        var filteredCues: [WebVTT.Cue] = []
        
        var prevCueLines: [String] = []
        var lastEnd: Int = 0
        for cue in cues {
            let isConsecutive = lastEnd == cue.timing.start
            lastEnd = cue.timing.end
            
            let lines = cue.contents.splitInLines()
            let linesText = lines.map { $0.string() }
            
            // Ignore lines that are empty or are just whitespace
            var ignored = lines
                .map { $0.string().trimmingCharacters(in: .whitespaces).isEmpty }
            
            // Ignore the lines that were in the previous cue.
            // Ignore only it the cues are consecutive and the line was at the same position or one lower.
            // The checks are there to lower the chance of ignoring repeating lines when applied on normal captions,
            // where repeated lines are expected for e.g. repeating dialogue.
            if isConsecutive {
                for i in 0..<lines.count where !ignored[i] {
                    let line = linesText[i]
                    ignored[i] = prevCueLines.item(at: i) == line || prevCueLines.item(at: i+1) == line
                }
            }
            
            let filteredLines = zip(lines, ignored)
                .compactMap { (line, isIgnored) in return isIgnored ? nil : line }
            
            let contents = WebVTT.Cue.Node(type: .root)
            filteredLines.enumerated().forEach { i, line in
                if i > 0 {
                    contents.children.append(WebVTT.Cue.Node(type: .text("\n")))
                }
                contents.children.append(contentsOf: line.children)
            }
            
            // Filter out cues that don't contain any characters
            guard !contents.isEmpty else { continue }
            prevCueLines = linesText
            filteredCues.append(WebVTT.Cue(timing: cue.timing, contents: contents))
        }
        
        return WebVTT(cues: filteredCues)
    }
}

// MARK: - 

fileprivate extension WebVTT.Cue.Node {
    // MARK: Deep split
    func splitInLines() -> [WebVTT.Cue.Node] {
        if case .text(let text) = type {
            return text.components(separatedBy: .newlines) // This is the most intensive operation. But maybe that's inevitable?
                .map { WebVTT.Cue.Node(type: .text($0)) }
        }
        
        var result: [WebVTT.Cue.Node] = []
        var buffer: [WebVTT.Cue.Node] = []
        
        for child in children {
            let split = child.splitInLines()
            split.enumerated()
                .forEach { i, line in
                    if i > 0 {
                        let node = emptyCopy()
                        node.children = buffer
                        result.append(node)
                        buffer = []
                    }
                    buffer.append(line)
            }
        }
        
        let node = emptyCopy()
        node.children = buffer
        result.append(node)
        
        return result
    }
    
    private func emptyCopy() -> WebVTT.Cue.Node {
        return WebVTT.Cue.Node(type: type, classes: classes, annotation: annotation)
    }
    
    // MARK: Text check
    
    var isEmpty: Bool {
        if case .text(let text) = type { return text.isEmpty }
        for child in children {
            if !child.isEmpty { return false }
        }
        return true
    }
}

// MARK: - Convenience

internal extension Collection {
    func item(at index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
