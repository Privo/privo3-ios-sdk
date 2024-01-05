//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

public struct AgeRange: Decodable, Encodable, Hashable {
    public let start: Int;
    public let end: Int;
    public let jurisdiction: String?;
}
