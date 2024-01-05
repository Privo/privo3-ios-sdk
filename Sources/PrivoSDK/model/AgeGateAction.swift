//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

public enum AgeGateAction: Int, Decodable, Encodable, Hashable {
    case Block = 0
    case Consent
    case IdentityVerify
    case AgeVerify
    case Allow
    case MultiUserBlock
    case AgeEstimationBlocked
}
