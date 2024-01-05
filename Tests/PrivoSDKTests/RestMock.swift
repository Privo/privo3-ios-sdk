//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
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



class RestMock: Restable {
    func addObjectToTMPStorage<T>(value: T, completionHandler: ((String?) -> Void)?) where T : Encodable {
        completionHandler?("")
    }
    
    func getObjectFromTMPStorage<T>(key: String, completionHandler: @escaping (T?) -> Void) where T : Decodable {
        completionHandler(nil)
    }
    
    func getServiceInfo(serviceIdentifier: String, completionHandler: @escaping (ServiceInfo?) -> Void) {
        completionHandler(nil)
    }

    func processStatus(data: StatusRecord) async throws -> AgeGateStatusResponse {
        throw PrivoError.noInternetConnection
    }
    
    func generateFingerprint(fingerprint: DeviceFingerprint) async throws -> DeviceFingerprintResponse {
        throw PrivoError.noInternetConnection
    }
    
    func getAuthSessionId() async -> String? {
        return nil
    }
    
    func renewToken(oldToken: String, sessionId: String) async -> String? {
        return nil
    }
    
    func getAgeServiceSettings(serviceIdentifier: String) async throws -> AgeServiceSettings {
        throw PrivoError.noInternetConnection
    }
    
    func getAgeVerification(verificationIdentifier: String) async -> AgeVerificationTO? {
        return nil
    }
    
    func processLinkUser(data: LinkUserStatusRecord) async throws -> AgeGateStatusResponse {
        throw PrivoError.noInternetConnection
    }
    
    func processBirthDate(data: FpStatusRecord) async throws -> AgeGateActionResponse {
        throw PrivoError.noInternetConnection
    }
    
    func processRecheck(data: RecheckStatusRecord) async throws -> AgeGateActionResponse {
        throw PrivoError.noInternetConnection
    }
    
    func trackCustomError(_ errorDescr: String) {}
    
    func sendAnalyticEvent(_ event: AnalyticEvent) {}
}
