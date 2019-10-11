import XCTest
@testable import Kinvey

final class KinveyTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Kinvey().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
