//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

struct VerificationData: Encodable {
    let profile: UserVerificationProfile
    let config: VerificationConfig
    var sourceOrigin: String?
    var redirectUrl: String?
}
