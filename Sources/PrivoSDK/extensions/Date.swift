//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

extension Date {
    
    func toMilliseconds() -> Int64 {
        Int64(self.timeIntervalSince1970 * 1000)
    }

    init(milliseconds:Int) {
        self = Date().advanced(by: TimeInterval(integerLiteral: Int64(milliseconds / 1000)))
    }
}
