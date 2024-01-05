//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

struct ServiceInfo: Decodable {
    let serviceIdentifier: String
    let apiKeys: Array<String>?
    let authMethods: Array<Int>?
    let p2siteId: Int?
}
