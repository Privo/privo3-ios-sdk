//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

public struct AgeVerificationEvent : Encodable, Decodable {
    
    public let status: AgeVerificationStatus
    
    /// child profile verified by PRIVO
    public let profile: AgeVerificationProfile?
}

struct AgeVerificationEventInternal: Encodable, Decodable {
    let status: AgeVerificationStatusInternal
    let profile: AgeVerificationProfile?
    let ageVerificationId: String?
}
