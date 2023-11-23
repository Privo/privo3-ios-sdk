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



class RestMock: IRest {
    func addObjectToTMPStorage<T>(value: T, completionHandler: ((String?) -> Void)?) where T : Encodable {
        completionHandler?("")
    }
    
    func getObjectFromTMPStorage<T>(key: String, completionHandler: @escaping (T?) -> Void) where T : Decodable {
        completionHandler(nil)
    }
    
    func getServiceInfo(serviceIdentifier: String, completionHandler: @escaping (ServiceInfo?) -> Void) {
        completionHandler(nil)
    }
    
    func processStatus(data: StatusRecord) async -> AgeGateStatusResponse? {
        return .mockUnavailable
    }
    
    func generateFingerprint(fingerprint: DeviceFingerprint) async -> DeviceFingerprintResponse? {
        return .mockSuccess
    }
    
    func getAuthSessionId() async -> String? {
        return nil
    }
    
    func renewToken(oldToken: String, sessionId: String) async -> String? {
        return nil
    }
    
    func getAgeServiceSettings(serviceIdentifier: String) async throws -> AgeServiceSettings? {
        return .mockSuccess
    }
    
    func getAgeVerification(verificationIdentifier: String) async -> AgeVerificationTO? {
        return nil
    }
    
    func processLinkUser(data: LinkUserStatusRecord) async -> AgeGateStatusResponse? {
        return .mockUnavailable
    }
    
    func processBirthDate(data: FpStatusRecord) async throws -> AgeGateActionResponse? {
        return nil
    }
    
    func processRecheck(data: RecheckStatusRecord) async throws -> AgeGateActionResponse? {
        return nil
    }
    
    func trackCustomError(_ errorDescr: String) {}
    
    func sendAnalyticEvent(_ event: AnalyticEvent) {}
}
