//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

struct AgeGateStoredEntity: Encodable, Decodable, Hashable {
    let userIdentifier: String?
    let nickname: String?
    let agId: String;
}
