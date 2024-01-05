//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
import XCTest

extension XCTestExpectation {
    
    func assertForOverFulfill(_ isOverFulfill: Bool) -> Self {
        self.assertForOverFulfill = isOverFulfill
        return self
    }
}
