//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.06.2021.
//

import Alamofire
import Foundation

class Rest {
    
    //MARK: - Static Shared object
    
    static var shared: Rest = .init()
    
    //MARK: - Private properties
    
    private static let storageComponent = "storage"
    private static let putComponent = "put"
    private static let sessionID = "session_id"
    private static let emptyResponsesCodes: Set<Int> = .init([200,204,205])
    
    //MARK: - Internal functions
    
    func getValueFromTMPStorage(key: String, completionHandler: @escaping (TmpStorageDataResponse?) -> Void) {
        var tmpStorageURL = PrivoService.configuration.helperUrl
        tmpStorageURL.appendPathComponent("storage")
        tmpStorageURL.appendPathComponent(key)
        AF.request(tmpStorageURL).responseDecodable(of: TmpStorageDataResponse.self) { response in
            self.trackPossibleAFError(response.error, response.response?.statusCode)
            completionHandler(response.value)
        }
    }
    
    func addValueToTMPStorage(value: String, ttl: Int? = nil, completionHandler: ((String?) -> Void)? = nil) {
        var tmpStorageURL = PrivoService.configuration.helperUrl
        tmpStorageURL.appendPathComponent("storage")
        tmpStorageURL.appendPathComponent("put")
        let data = TmpStorageDataResponse(data: value, ttl: ttl)
        AF.request(tmpStorageURL, method: .post, parameters: data, encoder: JSONParameterEncoder.default).responseDecodable(of: TmpStorageResponse.self) { response in
            self.trackPossibleAFError(response.error, response.response?.statusCode)
            let id = response.value?.id
            completionHandler?(id)
        }
    }
    
    func getObjectFromTMPStorage<T: Decodable>(key: String, completionHandler: @escaping (T?) -> Void) {
        getValueFromTMPStorage(key: key) { response in
            if let jsonString = response?.data,
               let jsonData = jsonString.data(using: .utf8),
               let value = try? JSONDecoder().decode(T.self, from: jsonData) {
                completionHandler(value)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func addObjectToTMPStorage<T: Encodable>(value: T, completionHandler: ((String?) -> Void)? = nil) {
        if let jsonData = try? JSONEncoder().encode(value) {
            let jsonString = String(decoding: jsonData, as: UTF8.self)
            addValueToTMPStorage(value: jsonString, completionHandler: completionHandler)
        } else {
            completionHandler?(nil)
        }
    }
    
    func getServiceInfo(serviceIdentifier: String, completionHandler: @escaping (ServiceInfoResponse?) -> Void) {
        let url = String(format: "%@/info/svc?service_identifier=%@", PrivoService.configuration.authBaseUrl.absoluteString, serviceIdentifier)
        AF.request(url).responseDecodable(of: ServiceInfoResponse.self) { r in
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            completionHandler(r.value)
        }
    }
    
    func getAuthSessionId(completionHandler: @escaping (String?) -> Void) {
        let authStartUrl = PrivoService.configuration.authStartUrl
        let sessionIdKey = "session_id"
        AF.request(authStartUrl).response() { r in
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            if let redirectUrl = r.response?.url {
                let components = URLComponents(url: redirectUrl, resolvingAgainstBaseURL: true)
                if let sessionId = components?.queryItems?.first(where: { $0.name == sessionIdKey })?.value {
                    completionHandler(sessionId)
                } else {
                    completionHandler(nil)
                }
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func renewToken(oldToken: String, sessionId: String, completionHandler: @escaping (String?) -> Void) {
        let loginUrl = String(format: "%@/privo/login/token?session_id=%@", PrivoService.configuration.authBaseUrl.absoluteString,sessionId)
        AF.request(loginUrl, method: .post, parameters: nil, encoding: BodyStringEncoding(body: oldToken)).responseDecodable(of: LoginResponse.self) { r in
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            let token = r.value?.token
            completionHandler(token)
        }
    }
    
    func processStatus(data: StatusRecord, completionHandler: @escaping (AgeGateStatusResponse?) -> Void) {
        let url = String(format: "%@/status", PrivoService.configuration.ageGateBaseUrl.absoluteString)
        AF.request(url, method: .put, parameters: data, encoder: JSONParameterEncoder.default).responseDecodable(of: AgeGateStatusResponse.self, emptyResponseCodes: [200, 204, 205] ) { r in
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            completionHandler(r.value)
        }
    }
    
    func processBirthDate(data: FpStatusRecord,
                          completionHandler: @escaping (AgeGateActionResponse?) -> Void,
                          ageEstimationHandler: @escaping (CustomServerErrorResponse) -> Void) {
        let url = String(format: "%@/birthdate", PrivoService.configuration.ageGateBaseUrl.absoluteString)
        AF.request(url,
                   method: .post,
                   parameters: data,
                   encoder: JSONParameterEncoder.default)
            .responseDecodable(of: AgeGateActionResponse.self,
                               emptyResponseCodes: [200, 204, 205]) { [weak self] r in
                guard let self = self else { return }
                self.trackPossibleAFError(r.error, r.response?.statusCode)
                guard let ageEstimationError = self.existedAgeEstimationError(r) else { completionHandler(r.value); return }
                ageEstimationHandler(ageEstimationError)
        }
    }
    
    func processRecheck(data: RecheckStatusRecord,
                        completionHandler: @escaping (AgeGateActionResponse?) -> Void,
                        ageEstimationHandler: @escaping (CustomServerErrorResponse) -> Void) {
        let url = String(format: "%@/recheck", PrivoService.configuration.ageGateBaseUrl.absoluteString)
        AF.request(url, method: .put, parameters: data, encoder: JSONParameterEncoder.default).responseDecodable(of: AgeGateActionResponse.self, emptyResponseCodes: [200, 204, 205] ) { [weak self] r in
            guard let self = self else { return }
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            guard let ageEstimationError = self.existedAgeEstimationError(r) else { completionHandler(r.value); return }
            ageEstimationHandler(ageEstimationError)
        }
    }
    
    func processLinkUser(data: LinkUserStatusRecord, completionHandler: @escaping (AgeGateStatusResponse?) -> Void) {
        let url = String(format: "%@/link-user", PrivoService.configuration.ageGateBaseUrl.absoluteString)
        AF.request(url, method: .post, parameters: data, encoder: JSONParameterEncoder.default).responseDecodable(of: AgeGateStatusResponse.self, emptyResponseCodes: [200, 204, 205] ) { r in
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            completionHandler(r.value)
        }
    }
    
    func getAgeServiceSettings(serviceIdentifier: String, completionHandler: @escaping (AgeServiceSettingsResponse?) -> Void) {
        let url = String(format: "%@/settings?service_identifier=%@", PrivoService.configuration.ageGateBaseUrl.absoluteString, serviceIdentifier)
        AF.request(url).responseDecodable(of: AgeServiceSettingsResponse.self) { r in
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            completionHandler(r.value)
        }
    }
    
    func getAgeVerification(verificationIdentifier: String, completionHandler: @escaping (AgeVerificationResponse?) -> Void) {
        let url = String(format: "%@/age-verification?verification_identifier=%@", PrivoService.configuration.ageVerificationBaseUrl.absoluteString, verificationIdentifier)
        AF.request(url).responseDecodable(of: AgeVerificationResponse.self) { r in
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            completionHandler(r.value)
        }
    }
    
    func generateFingerprint(fingerprint: DeviceFingerprint, completionHandler: @escaping (DeviceFingerprintResponse?) -> Void) {
        let url = String(format: "%@/fp", PrivoService.configuration.authBaseUrl.absoluteString)
        AF.request(url, method: .post, parameters: fingerprint, encoder: JSONParameterEncoder.default).responseDecodable(of: DeviceFingerprintResponse.self ) { r in
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            completionHandler(r.value)
        }
    }
    
    func trackCustomError(_ description: String) {
        let settings = PrivoService.settings;
        let data = AnalyticEventErrorData(errorMessage: description, errorCode: nil, privoSettings: settings)
        let event = AnalyticEvent(serviceIdentifier: PrivoService.settings.serviceIdentifier, data: data)
        sendAnalyticEvent(event)
    }
    
    func trackPossibleAFError(_ error: AFError?, _ code: Int?) {
        guard code != 200 && code != 204 && code != 205 else { return }
        guard let error = error else { return }
        let data = AnalyticEventErrorData(errorMessage: error.errorDescription,
                                          errorCode: error.responseCode, privoSettings: nil)
        let event = AnalyticEvent(serviceIdentifier: PrivoService.settings.serviceIdentifier, data: data)
        sendAnalyticEvent(event)
    }
    
    func sendAnalyticEvent(_ event: AnalyticEvent) {
        var metricsURL = PrivoService.configuration.helperUrl
        metricsURL.appendPathComponent("metrics")
        AF.request(metricsURL, method: .post, parameters: event, encoder: JSONParameterEncoder.default).response { r in
            print("Analytic Event Sent")
            print(r)
        }
    }
    
    func checkNetwork() throws {
        let rManager = NetworkReachabilityManager()
        if (rManager?.isReachable == false) {
            throw PrivoError.noInternetConnection
        }
    }
    
    func getValueFromTMPStorage(key: String) async -> TmpStorageDataResponse? {
        var tmpStorageURL = PrivoService.configuration.helperUrl
        tmpStorageURL.appendPathComponent(Rest.storageComponent)
        tmpStorageURL.appendPathComponent(key)
        let response: DataResponse<TmpStorageDataResponse,AFError> = await AF.request(tmpStorageURL)
        trackPossibleAFError(response.error, response.response?.statusCode)
        return response.value
    }
    
    func addValueToTMPStorage(value: String, ttl: Int? = nil) async -> String? {
        var tmpStorageURL = PrivoService.configuration.helperUrl
        tmpStorageURL.appendPathComponent(Rest.storageComponent)
        tmpStorageURL.appendPathComponent(Rest.putComponent)
        let data = TmpStorageDataResponse(data: value, ttl: ttl)
        typealias R = DataResponse<TmpStorageResponse,AFError>
        let result: R = await AF.request(tmpStorageURL, method: .post, parameter: data)
        trackPossibleAFError(result.error, result.response?.statusCode)
        let id = result.value?.id
        return id
    }
    
    func getObjectFromTMPStorage<T: Decodable>(key: String) async -> T? {
        let response = await getValueFromTMPStorage(key: key)
        guard let jsonString = response?.data,
              let jsonData = jsonString.data(using: .utf8),
              let value = try? JSONDecoder().decode(T.self, from: jsonData) else { return nil }
        return value
    }
    
    func addObjectToTMPStorage<T: Encodable>(value: T) async -> String? {
        guard let jsonData = try? JSONEncoder().encode(value) else { return nil }
        let jsonString = String(decoding: jsonData, as: UTF8.self)
        let result = await addValueToTMPStorage(value: jsonString)
        return result
    }
    
    func getServiceInfo(serviceIdentifier: String) async -> ServiceInfoResponse? {
        let url = String(format: "%@/info/svc?service_identifier=%@", PrivoService.configuration.authBaseUrl.absoluteString, serviceIdentifier)
        let result: DataResponse<ServiceInfoResponse,AFError> = await AF.request(url)
        trackPossibleAFError(result.error, result.response?.statusCode)
        return result.value
    }
    
    func getAuthSessionId() async -> String? {
        let authStartUrl = PrivoService.configuration.authStartUrl
        let sessionIdKey = Rest.sessionID
        let result = await AF.request(authStartUrl)
        trackPossibleAFError(result.error, result.response?.statusCode)
        guard let redirectUrl = result.response?.url,
              let components = URLComponents(url: redirectUrl, resolvingAgainstBaseURL: true),
              let sessionId = components.queryItems?.first(where: { $0.name == sessionIdKey })?.value else {
            return nil
        }
        return sessionId
    }
    
    func renewToken(oldToken: String, sessionId: String) async -> String? {
        let loginUrl = String(format: "%@/privo/login/token?session_id=%@", PrivoService.configuration.authBaseUrl.absoluteString,sessionId)
        typealias R = DataResponse<LoginResponse,AFError>
        let result: R = await AF.request(loginUrl, method: .post, encoding: BodyStringEncoding(body: oldToken))
        trackPossibleAFError(result.error, result.response?.statusCode)
        let token = result.value?.token
        return token
    }
    
    func processStatus(data: StatusRecord) async -> AgeGateStatusResponse? {
        let url = String(format: "%@/status", PrivoService.configuration.ageGateBaseUrl.absoluteString)
        typealias R = DataResponse<AgeGateStatusResponse,AFError>
        let result: R = await AF.request(url, method: .put, parameters: data, emptyResponseCodes: Rest.emptyResponsesCodes)
        trackPossibleAFError(result.error, result.response?.statusCode)
        return result.value
    }
    
    func processBirthDate(data: FpStatusRecord) async throws -> AgeGateActionResponse? {
        let url = String(format: "%@/birthdate", PrivoService.configuration.ageGateBaseUrl.absoluteString)
        typealias R = DataResponse<AgeGateActionResponse,AFError>
        let result: R = await AF.request(url,
                                         method: .post,
                                         parameter: data,
                                         encoder: JSONParameterEncoder.default,
                                         emptyResponseCodes: Rest.emptyResponsesCodes)
        trackPossibleAFError(result.error, result.response?.statusCode)
        if let ageEstimationError = existedAgeEstimationError(result) { throw ageEstimationError }
        return result.value
    }
    
    func processRecheck(data: RecheckStatusRecord) async throws -> AgeGateActionResponse? {
        let url = String(format: "%@/recheck", PrivoService.configuration.ageGateBaseUrl.absoluteString)
        typealias R = DataResponse<AgeGateActionResponse,AFError>
        let result: R = await AF.request(url, method: .put, parameters: data, emptyResponseCodes: Rest.emptyResponsesCodes)
        trackPossibleAFError(result.error, result.response?.statusCode)
        if let ageEstimationError = existedAgeEstimationError(result) {
            throw ageEstimationError
        }
        return result.value
    }
    
    func processLinkUser(data: LinkUserStatusRecord) async -> AgeGateStatusResponse? {
        let url = String(format: "%@/link-user", PrivoService.configuration.ageGateBaseUrl.absoluteString)
        typealias R = DataResponse<AgeGateStatusResponse,AFError>
        let result: R = await AF.request(url, method: .post, parameters: data, emptyResponseCodes: Rest.emptyResponsesCodes)
        trackPossibleAFError(result.error, result.response?.statusCode)
        return result.value
    }
    
    func getAgeServiceSettings(serviceIdentifier: String) async throws -> AgeServiceSettingsResponse? {
        let url = String(format: "%@/settings?service_identifier=%@", PrivoService.configuration.ageGateBaseUrl.absoluteString, serviceIdentifier)
        let result: DataResponse<AgeServiceSettingsResponse,AFError> = await AF.request(url)
        trackPossibleAFError(result.error, result.response?.statusCode)
        return result.value
    }
    
    func getAgeVerification(verificationIdentifier: String) async -> AgeVerificationResponse? {
        let url = String(format: "%@/age-verification?verification_identifier=%@", PrivoService.configuration.ageVerificationBaseUrl.absoluteString, verificationIdentifier)
        let result: DataResponse<AgeVerificationResponse,AFError> = await AF.request(url)
        trackPossibleAFError(result.error, result.response?.statusCode)
        return result.value
    }
    
    func generateFingerprint(fingerprint: DeviceFingerprint) async -> DeviceFingerprintResponse? {
        let url = String(format: "%@/fp", PrivoService.configuration.authBaseUrl.absoluteString)
        typealias R = DataResponse<DeviceFingerprintResponse,AFError>
        let result: R = await AF.request(url, method: .post, parameters: fingerprint)
        trackPossibleAFError(result.error, result.response?.statusCode)
        return result.value
    }
    
    //MARK: - Private functions
    
    private func existedAgeEstimationError<T:Decodable>(_ response: DataResponse<T,AFError>) -> CustomServerErrorResponse? {
        guard response.response?.statusCode == 500,
              let data = response.data,
              let customServiceError = try? JSONDecoder().decode(CustomServerErrorResponse.self, from: data),
              customServiceError.code == CustomServerErrorResponse.AGE_ESTIMATION_ERROR else { return nil }
        return customServiceError
    }

}
