//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

internal struct AgeGateActionResponse: Decodable, Encodable, Hashable {
    let action: AgeGateAction;
    let agId: String;
    let ageRange: AgeRange?
    let extUserId: String?
    let countryCode: String?
}
internal struct AgeGateStatusResponse: Decodable, Encodable, Hashable {
    let status: AgeGateStatusTO;
    let agId: String?;
    let ageRange: AgeRange?
    let extUserId: String?
    let countryCode: String?
}
