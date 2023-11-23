//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.06.2021.
//

import Alamofire
import Foundation


struct URLComponentConstants: ExpressibleByStringLiteral, RawRepresentable {
    let rawValue: String

    init(stringLiteral value: String) {
        rawValue = value
    }
    
    init(rawValue value: String) {
        rawValue = value
    }
}

extension URLComponentConstants {
    static let analytic: URLComponentConstants = "metrics"
    static let status: URLComponentConstants = "status"
    static let api: URLComponentConstants = "api"
    static let v1_0: URLComponentConstants = "v1.0"
    static let fingerprint: URLComponentConstants = "fp"
    static let settings: URLComponentConstants = "settings"
}

extension URL {
    func appending(_ component: URLComponentConstants) -> URL {
        return self.appendingPathComponent(component.rawValue)
    }
    
    func hasSuffix(_ component: URLComponentConstants) -> Bool {
        return self.absoluteString.hasSuffix(component.rawValue)
    }
}

protocol IRest {
    func addObjectToTMPStorage<T: Encodable>(value: T, completionHandler: ((String?) -> Void)?)
    func getObjectFromTMPStorage<T: Decodable>(key: String, completionHandler: @escaping (T?) -> Void)
    func getServiceInfo(serviceIdentifier: String, completionHandler: @escaping (ServiceInfo?) -> Void)
    
    func processStatus(data: StatusRecord) async -> AgeGateStatusResponse?
    func generateFingerprint(fingerprint: DeviceFingerprint) async -> DeviceFingerprintResponse?
    func getAuthSessionId() async -> String?
    func renewToken(oldToken: String, sessionId: String) async -> String?
    func getAgeServiceSettings(serviceIdentifier: String) async throws -> AgeServiceSettings?
    func getAgeVerification(verificationIdentifier: String) async -> AgeVerificationTO?
    func processLinkUser(data: LinkUserStatusRecord) async -> AgeGateStatusResponse?
    func processBirthDate(data: FpStatusRecord) async throws -> AgeGateActionResponse?
    func processRecheck(data: RecheckStatusRecord) async throws -> AgeGateActionResponse?
    func trackCustomError(_ errorDescr: String)
    func sendAnalyticEvent(_ event: AnalyticEvent)
}

class Rest: IRest {
    
    //MARK: - Static Shared object
    
    static var shared: Rest = Rest()
    
    init(urlConfig: URLSessionConfiguration = URLSessionConfiguration.af.default) {
        self.urlConfig = urlConfig
        self.session = Session(configuration: urlConfig)
    }
    
    //MARK: - Private properties
    
    private static let storageComponent = "storage"
    private static let putComponent = "put"
    private static let sessionID = "session_id"
    private static let emptyResponsesCodes: Set<Int> = .init([200,204,205])
    
    private let urlConfig: URLSessionConfiguration
    private let session: Session
    
    //MARK: - Internal functions
    
    func getValueFromTMPStorage(key: String, completionHandler: @escaping (TmpStorageString?) -> Void) {
        Task.init {
            let result = await getValueFromTMPStorage(key: key)
            completionHandler(result)
        }
    }
    
    func addValueToTMPStorage(value: String, ttl: Int? = nil, completionHandler: ((String?) -> Void)? = nil) {
        Task.init {
            let result = await addValueToTMPStorage(value: value, ttl: ttl)
            completionHandler?(result)
        }
    }
    
    func getObjectFromTMPStorage<T: Decodable>(key: String, completionHandler: @escaping (T?) -> Void) {
        Task.init {
            let result:T? = await getObjectFromTMPStorage(key: key)
            completionHandler(result)
        }
    }
    
    func addObjectToTMPStorage<T: Encodable>(value: T, completionHandler: ((String?) -> Void)? = nil) {
        Task.init {
            let result = await addObjectToTMPStorage(value: value)
            completionHandler?(result)
        }
    }
    
    func getServiceInfo(serviceIdentifier: String, completionHandler: @escaping (ServiceInfo?) -> Void) {
        Task.init {
            let result = await getServiceInfo(serviceIdentifier: serviceIdentifier)
            completionHandler(result)
        }
    }
    
    func getAuthSessionId(completionHandler: @escaping (String?) -> Void) {
        Task.init {
            let result = await getAuthSessionId()
            completionHandler(result)
        }
    }
    
    func renewToken(oldToken: String, sessionId: String, completionHandler: @escaping (String?) -> Void) {
        Task.init {
            let result = await renewToken(oldToken: oldToken, sessionId: sessionId)
            completionHandler(result)
        }
    }
    
    func processStatus(data: StatusRecord, completionHandler: @escaping (AgeGateStatusResponse?) -> Void) {
        Task.init {
            let result = await processStatus(data: data)
            completionHandler(result)
        }
    }
    
    func processBirthDate(data: FpStatusRecord,
                          completionHandler: @escaping (AgeGateActionResponse?) -> Void,
                          ageEstimationHandler: @escaping (CustomServerErrorResponse) -> Void) {
        Task.init {
            do {
                let result = try await processBirthDate(data: data)
                completionHandler(result)
            } catch let error {
                if let error = error as? CustomServerErrorResponse {
                    ageEstimationHandler(error)
                }
            }
        }
    }
    
    func processRecheck(data: RecheckStatusRecord,
                        completionHandler: @escaping (AgeGateActionResponse?) -> Void,
                        ageEstimationHandler: @escaping (CustomServerErrorResponse) -> Void) {
        Task.init {
            do {
                let result = try await processRecheck(data: data)
                completionHandler(result)
            } catch let error {
                if let error = error as? CustomServerErrorResponse {
                    ageEstimationHandler(error)
                }
            }
        }
    }
    
    func processLinkUser(data: LinkUserStatusRecord, completionHandler: @escaping (AgeGateStatusResponse?) -> Void) {
        Task.init {
            let result = await processLinkUser(data: data)
            completionHandler(result)
        }
    }
    
    func getAgeServiceSettings(serviceIdentifier: String, completionHandler: @escaping (AgeServiceSettings?) -> Void) {
        Task.init {
            let result = try? await getAgeServiceSettings(serviceIdentifier: serviceIdentifier)
            completionHandler(result)
        }
    }
    
    func getAgeVerification(verificationIdentifier: String, completionHandler: @escaping (AgeVerificationTO?) -> Void) {
        Task.init {
            let result = await getAgeVerification(verificationIdentifier: verificationIdentifier)
            completionHandler(result)
        }
    }
    
    func generateFingerprint(fingerprint: DeviceFingerprint, completionHandler: @escaping (DeviceFingerprintResponse?) -> Void) {
        Task.init {
            let result = await generateFingerprint(fingerprint: fingerprint)
            completionHandler(result)
        }
    }
    
    func trackCustomError(_ errorDescr: String) {
        let settings = PrivoInternal.settings;
        let data = AnalyticEventErrorData(errorMessage: errorDescr, response: nil, errorCode: nil, privoSettings: settings)
        if let jsonData = try? JSONEncoder().encode(data) {
            let jsonString = String(decoding: jsonData, as: UTF8.self)
            let event = AnalyticEvent(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, data: jsonString)
            sendAnalyticEvent(event)
        }
    }
    
    func trackPossibleAFError(_ error: AFError?, _ response: String?, _ code: Int?) {
        let encoder = JSONEncoder()
        let analyticErrorEvent: AnalyticEventErrorData?
        
        if (code != 200 && code != 204 && code != 205) {
            // This branch for HTTP errors.
            analyticErrorEvent = AnalyticEventErrorData(errorMessage: nil,
                                                        response: response,
                                                        errorCode: code,
                                                        privoSettings: nil)
        } else if let error = error {
            // This branch for:
            // - underlying errors like network request timeout,
            // - (overlying) decoding parsing error.
            analyticErrorEvent = AnalyticEventErrorData(errorMessage: error.errorDescription,
                                                        response: response,
                                                        errorCode: error.responseCode,
                                                        privoSettings: nil)
        } else {
            analyticErrorEvent = nil
        }
        
        if let analyticErrorEvent,
           let jsonData = try? encoder.encode(analyticErrorEvent) {
            let jsonString = String(decoding: jsonData, as: UTF8.self)
            let analyticEvent = AnalyticEvent(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, data: jsonString)
            sendAnalyticEvent(analyticEvent)
        }
    }
    
    func sendAnalyticEvent(_ event: AnalyticEvent) {
        let url = PrivoInternal.configuration.commonUrl.appending(.analytic)
        session.request(url, method: .post, parameters: event, encoder: JSONParameterEncoder.default).response { r in
            print("Analytic Event Sent")
            print(r)
        }
    }
        
    func getValueFromTMPStorage(key: String) async -> TmpStorageString? {
        var tmpStorageURL = PrivoInternal.configuration.commonUrl
        tmpStorageURL = tmpStorageURL.append([Rest.storageComponent, key])
        let response: DataResponse<TmpStorageString,AFError> = await session.request(tmpStorageURL)
        trackPossibleAFError(response.error, response.debugDescription, response.response?.statusCode)
        return response.value
    }
    
    func addValueToTMPStorage(value: String, ttl: Int? = nil) async -> String? {
        var tmpStorageURL = PrivoInternal.configuration.commonUrl
        tmpStorageURL = tmpStorageURL.append([Rest.storageComponent, Rest.putComponent])
        let data = TmpStorageString(data: value, ttl: ttl)
        typealias R = DataResponse<TmpStorageResponse,AFError>
        let result: R = await session.request(tmpStorageURL, method: .post, parameter: data, encoder: JSONParameterEncoder.default)
        trackPossibleAFError(result.error, result.debugDescription, result.response?.statusCode)
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
    
    func getServiceInfo(serviceIdentifier: String) async -> ServiceInfo? {
        var url = PrivoInternal.configuration.authBaseUrl
        url = url.append(["api", "v1.0", "info", "svc"])
        var urlComponent = url.urlComponent()
        urlComponent.queryItems = [.init(name: "service_identifier", value: serviceIdentifier)]
        url = urlComponent.url ?? url
        let result: DataResponse<ServiceInfo,AFError> = await session.request(url)
        trackPossibleAFError(result.error, result.debugDescription, result.response?.statusCode)
        return result.value
    }
    
    func getAuthSessionId() async -> String? {
        var url = PrivoInternal.configuration.authBaseUrl
        url = url.append(["authorize"])
        var urlComponent = url.urlComponent()
        urlComponent.queryItems = [
            .init(name: "client_id", value: "mobile"),
            .init(name: "redirect_uri", value: "")
        ]
        url = urlComponent.url ?? url
        let result = await session.request(url)
        trackPossibleAFError(result.error, result.debugDescription, result.response?.statusCode)
        guard let redirectUrl = result.response?.url,
              let components = URLComponents(url: redirectUrl, resolvingAgainstBaseURL: true),
              let sessionId = components.queryItems?.first(where: { $0.name == Rest.sessionID })?.value else {
            return nil
        }
        return sessionId
    }
    
    func renewToken(oldToken: String, sessionId: String) async -> String? {
        var url = PrivoInternal.configuration.authBaseUrl
        url = url.append(["api", "v1.0", "privo", "login", "token"])
        var urlComponent = url.urlComponent()
        urlComponent.queryItems = [.init(name: "session_id", value: sessionId)]
        url = urlComponent.url ?? url
        typealias R = DataResponse<LoginResponse,AFError>
        let result: R = await session.request(url, method: .post, encoding: BodyStringEncoding(body: oldToken))
        trackPossibleAFError(result.error, result.debugDescription, result.response?.statusCode)
        let token = result.value?.token
        return token
    }
    
    func processStatus(data: StatusRecord) async -> AgeGateStatusResponse? {
        let url = PrivoInternal.configuration.ageGateBaseUrl.appending(.status)
        typealias R = DataResponse<AgeGateStatusResponse,AFError>
        let result: R = await session.request(url.absoluteString,
                                         method: .put,
                                         parameters: data,
                                         encoder: JSONParameterEncoder.default,
                                         emptyResponseCodes: Rest.emptyResponsesCodes)
        trackPossibleAFError(result.error, result.debugDescription, result.response?.statusCode)
        return result.value
    }
    
    func processBirthDate(data: FpStatusRecord) async throws -> AgeGateActionResponse? {
        let url = String(format: "%@/birthdate", PrivoInternal.configuration.ageGateBaseUrl.absoluteString)
        typealias R = DataResponse<AgeGateActionResponse,AFError>
        let result: R = await session.request(url,
                                         method: .post,
                                         parameter: data,
                                         encoder: JSONParameterEncoder.default,
                                         emptyResponseCodes: Rest.emptyResponsesCodes)
        trackPossibleAFError(result.error, result.debugDescription, result.response?.statusCode)
        if let ageEstimationError = existedAgeEstimationError(result) { throw ageEstimationError }
        return result.value
    }
    
    func processRecheck(data: RecheckStatusRecord) async throws -> AgeGateActionResponse? {
        let url = String(format: "%@/recheck", PrivoInternal.configuration.ageGateBaseUrl.absoluteString)
        typealias R = DataResponse<AgeGateActionResponse,AFError>
        let result: R = await session.request(url,
                                         method: .put,
                                         parameters: data,
                                         encoder: JSONParameterEncoder.default,
                                         emptyResponseCodes: Rest.emptyResponsesCodes)
        trackPossibleAFError(result.error, result.debugDescription, result.response?.statusCode)
        if let ageEstimationError = existedAgeEstimationError(result) {
            throw ageEstimationError
        }
        return result.value
    }
    
    func processLinkUser(data: LinkUserStatusRecord) async -> AgeGateStatusResponse? {
        let url = String(format: "%@/link-user", PrivoInternal.configuration.ageGateBaseUrl.absoluteString)
        typealias R = DataResponse<AgeGateStatusResponse,AFError>
        let result: R = await session.request(url,
                                         method: .post,
                                         parameters: data,
                                         encoder: JSONParameterEncoder.default,
                                         emptyResponseCodes: Rest.emptyResponsesCodes)
        trackPossibleAFError(result.error, result.debugDescription, result.response?.statusCode)
        return result.value
    }
    
    func getAgeServiceSettings(serviceIdentifier: String) async throws -> AgeServiceSettings? {
        guard let url = PrivoInternal.configuration.ageGateBaseUrl.appending(.settings).withQueryParam(name: "service_identifier", value: serviceIdentifier) else {
            // unreachable branch
            return nil
        }
        
        let result: DataResponse<AgeServiceSettings,AFError> = await session.request(url)
        trackPossibleAFError(result.error, result.debugDescription, result.response?.statusCode)
        return result.value
    }
    
    func getAgeVerification(verificationIdentifier: String) async -> AgeVerificationTO? {
        let url = String(format: "%@/age-verification?verification_identifier=%@", PrivoInternal.configuration.ageVerificationBaseUrl.absoluteString, verificationIdentifier)
        let result: DataResponse<AgeVerificationTO,AFError> = await session.request(url)
        trackPossibleAFError(result.error, result.debugDescription, result.response?.statusCode)
        return result.value
    }
    
    func generateFingerprint(fingerprint: DeviceFingerprint) async -> DeviceFingerprintResponse? {
        let url = PrivoInternal.configuration.authBaseUrl.appending(.api).appending(.v1_0).appending(.fingerprint)
        typealias R = DataResponse<DeviceFingerprintResponse,AFError>
        let result: R = await session.request(url, method: .post, parameters: fingerprint, encoder: JSONParameterEncoder.default)
        trackPossibleAFError(result.error,  result.debugDescription, result.response?.statusCode)
        return result.value
    }
    
    //MARK: - Private functions
    
    private func existedAgeEstimationError<T:Decodable>(_ response: DataResponse<T,AFError>) -> CustomServerErrorResponse? {
        guard let data = response.data,
              let customServiceError = try? JSONDecoder().decode(CustomServerErrorResponse.self, from: data),
              customServiceError.code == CustomServerErrorResponse.AGE_ESTIMATION_ERROR else { return nil }
        return customServiceError
    }

}
