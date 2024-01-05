//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

internal struct AgeServiceSettings: Encodable, Decodable {
    let isGeoApiOn: Bool
    let isAllowSelectCountry: Bool
    let isProvideUserId: Bool
    let isShowStatusUi: Bool
    let poolAgeGateStatusInterval: Int
    let verificationApiKey: String?
    let p2SiteId: Int?
    let logoUrl: String?
    let customerSupportEmail: String?
    let isMultiUserOn: Bool
}

