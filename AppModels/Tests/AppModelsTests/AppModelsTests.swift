import XCTest
@testable import AppModels

final class AppModelsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(AppModels().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
