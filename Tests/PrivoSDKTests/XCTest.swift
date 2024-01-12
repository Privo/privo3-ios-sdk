import Foundation
import XCTest

extension XCTestExpectation {
    
    func assertForOverFulfill(_ isOverFulfill: Bool) -> Self {
        self.assertForOverFulfill = isOverFulfill
        return self
    }
}
