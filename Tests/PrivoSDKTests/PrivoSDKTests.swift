    import XCTest
    @testable import PrivoSDK

    final class PrivoSDKTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
            XCTAssertEqual(PrivoInternal.configuration.type, .Dev)
        }
    }
