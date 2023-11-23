//
//  File.swift
//  
//
//  Created by Andrey Yo on 23.11.2023.
//


import Foundation
@testable import PrivoSDK


extension DeviceFingerprintResponse {
    static let mockSuccess: DeviceFingerprintResponse = .init(
        id: "uVH-v-fWp9oyENrNBJDllY==",
        exp: 1701247108
    )
}

extension AgeServiceSettings {
    static let mockSuccess: AgeServiceSettings = .init(
        isGeoApiOn: false,
        isAllowSelectCountry: true,
        isProvideUserId: true,
        isShowStatusUi: false,
        poolAgeGateStatusInterval: 15,
        verificationApiKey: "eMVAU4Qk4qrnOtH9GAHOafatybW8xQDg",
        p2SiteId: 1,
        logoUrl: nil,
        customerSupportEmail: nil,
        isMultiUserOn: true
    )
}

extension AgeGateStatusResponse {
    static let mockUnavailable: AgeGateStatusResponse = .init(
        status: .Undefined,
        agId: nil,
        ageRange: nil,
        extUserId: nil,
        countryCode: nil
    )
}

