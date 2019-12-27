import XCTest
@testable import CustomP

final class CustomPTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CustomP().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
