import XCTest
@testable import SwiftWebVTT

class SwiftWebVTTTests: XCTestCase {

    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Cases

    func testEntitiesResolution() {
        let encodedURL = url(forResource: "entities_encoded", withExtension: "txt")
        var encoded = try! String(contentsOf: encodedURL)
        encoded = encoded.decodingHTMLEntities()
        
        let decodedURL = url(forResource: "entities_decoded", withExtension: "txt")
        let decoded = try! String(contentsOf: decodedURL)
        
        XCTAssert(encoded == decoded, "Can't correctly decode HTML entities.")
    }
    
    // Sample WebVTT files not included
//    func testPerformance() {
//        self.measure {
//            load(name: "large")
//        }
//    }
//
//    @discardableResult
//    func load(name: String) -> WebVTT {
//        let fileURL = url(forResource: name, withExtension: "vtt")
//        let fileContents = try! String(contentsOf: fileURL)
//        let webVTT = try! WebVTTParser(string: fileContents).parse()
//        return webVTT
//    }
    
    // MARK: - Convenience
    
    func url(forResource name: String, withExtension ext: String?) -> URL {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: name, withExtension: ext)
        XCTAssertNotNil(url, "Resource \(name + (ext != nil ? ".\(ext!)" : "")) not found.")
        return url!
    }

}
