import Foundation

internal extension Collection {
    func item(at index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

internal extension String {
    func characters() -> [Character] { return Array(self) }
}
