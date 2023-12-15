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

protocol Restable {
    func addObjectToTMPStorage<T: Encodable>(value: T, completionHandler: ((String?) -> Void)?)
    func getObjectFromTMPStorage<T: Decodable>(key: String, completionHandler: @escaping (T?) -> Void)
    func getServiceInfo(serviceIdentifier: String, completionHandler: @escaping (ServiceInfo?) -> Void)
    
    func processStatus(data: StatusRecord) async -> AgeGateStatusResponse?
    func generateFingerprint(fingerprint: DeviceFingerprint) async throws -> DeviceFingerprintResponse
    func getAuthSessionId() async -> String?
    func renewToken(oldToken: String, sessionId: String) async -> String?
    func getAgeServiceSettings(serviceIdentifier: String) async throws -> AgeServiceSettings
    func getAgeVerification(verificationIdentifier: String) async -> AgeVerificationTO?
    func processLinkUser(data: LinkUserStatusRecord) async -> AgeGateStatusResponse?
    func processBirthDate(data: FpStatusRecord) async throws -> AgeGateActionResponse
    func processRecheck(data: RecheckStatusRecord) async throws -> AgeGateActionResponse
    func trackCustomError(_ errorDescr: String)
    func sendAnalyticEvent(_ event: AnalyticEvent)
}

class Rest: Restable {
    
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
    private static let acceptableStatusCodes: Set<Int> = [200, 204, 205]
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
        Task {
            do {
                let result = try await generateFingerprint(fingerprint: fingerprint)
                completionHandler(result)
            } catch {
                completionHandler(nil)
            }
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
    
    func trackPossibleAFError(_ error: AFError?, _ response: String?) {
        if let error = error {
            let analyticErrorEvent = AnalyticEventErrorData(
                errorMessage: error.errorDescription,
                response: response,
                errorCode: error.responseCode,
                privoSettings: nil
            )
            
            let encoder = JSONEncoder()
            if  let jsonData = try? encoder.encode(analyticErrorEvent) {
                let jsonString = String(decoding: jsonData, as: UTF8.self)
                let analyticEvent = AnalyticEvent(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, data: jsonString)
                sendAnalyticEvent(analyticEvent)
            }
        }
    }
    
    func trackPossibleAFErrorAndReturn<T>(_ response: AFDataResponse<T>) throws /*(PrivoError)*/ -> T {
        let error: AFError? = response.error
        let description: String? = response.debugDescription
        
        if let error = error {
            let analyticErrorEvent = AnalyticEventErrorData(
                errorMessage: error.errorDescription,
                response: description,
                errorCode: error.responseCode,
                privoSettings: nil
            )
            
            let encoder = JSONEncoder()
            if  let jsonData = try? encoder.encode(analyticErrorEvent) {
                let jsonString = String(decoding: jsonData, as: UTF8.self)
                let analyticEvent = AnalyticEvent(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, data: jsonString)
                sendAnalyticEvent(analyticEvent)
            }
            
            switch error {
            case let .sessionTaskFailed(error: error):
                let nserror = error as NSError
                switch nserror.code {
                case NSURLErrorNotConnectedToInternet:
                    throw PrivoError.noInternetConnection
                default:
                    throw PrivoError.networkConnectionProblem(nserror)
                }
                
            default:
                throw PrivoError.networkConnectionProblem(error.underlyingError)
            }
        }
        
        if let result = response.value {
            return result
        } else {
            throw PrivoError.networkConnectionProblem(nil)
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
        let response: AFDataResponse<TmpStorageString> = await session.request(tmpStorageURL, acceptableStatusCodes: Rest.acceptableStatusCodes)
        trackPossibleAFError(response.error, response.debugDescription)
        return response.value
    }
    
    func addValueToTMPStorage(value: String, ttl: Int? = nil) async -> String? {
        var tmpStorageURL = PrivoInternal.configuration.commonUrl
        tmpStorageURL = tmpStorageURL.append([Rest.storageComponent, Rest.putComponent])
        let data = TmpStorageString(data: value, ttl: ttl)
        let result: AFDataResponse<TmpStorageResponse> = await session.request(
            tmpStorageURL,
            method: .post,
            parameters: data,
            encoder: JSONParameterEncoder.default,
            acceptableStatusCodes: Rest.acceptableStatusCodes
        )
        trackPossibleAFError(result.error, result.debugDescription)
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
        let result: AFDataResponse<ServiceInfo> = await session.request(url, acceptableStatusCodes: Rest.acceptableStatusCodes)
        trackPossibleAFError(result.error, result.debugDescription)
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
        let result: AFDataResponse<Data?> = await session.request(url, acceptableStatusCodes: Rest.acceptableStatusCodes)
        trackPossibleAFError(result.error, result.debugDescription)
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
        let result: AFDataResponse<LoginResponse> = await session.request(
            url,
            method: .post,
            encoding: BodyStringEncoding(body: oldToken),
            acceptableStatusCodes: Rest.acceptableStatusCodes
        )
        trackPossibleAFError(result.error, result.debugDescription)
        let token = result.value?.token
        return token
    }
    
    func processStatus(data: StatusRecord) async -> AgeGateStatusResponse? {
        let url = PrivoInternal.configuration.ageGateBaseUrl.appending(.status)
        let result: AFDataResponse<AgeGateStatusResponse> = await session.request(url.absoluteString,
                                         method: .put,
                                         parameters: data,
                                         encoder: JSONParameterEncoder.default,
                                         acceptableStatusCodes: Rest.acceptableStatusCodes,
                                         emptyResponseCodes: Rest.emptyResponsesCodes)
        trackPossibleAFError(result.error, result.debugDescription)
        return result.value
    }
    
    func processBirthDate(data: FpStatusRecord) async throws /*(PrivoError or CustomServerErrorResponse)*/ -> AgeGateActionResponse {
        let url = String(format: "%@/birthdate", PrivoInternal.configuration.ageGateBaseUrl.absoluteString)
        
        let response: AFDataResponse<AgeGateActionResponse> = await session.request(
            url,
            method: .post,
            parameters: data,
            encoder: JSONParameterEncoder.default,
            acceptableStatusCodes: Rest.acceptableStatusCodes,
            emptyResponseCodes: Rest.emptyResponsesCodes
        )
        if let ageEstimationError = existedAgeEstimationError(response) {
            throw ageEstimationError
        }
        let result = try trackPossibleAFErrorAndReturn(response)
        return result
    }
    
    func processRecheck(data: RecheckStatusRecord) async throws /*(PrivoError or CustomServerErrorResponse)*/ -> AgeGateActionResponse {
        let url = String(format: "%@/recheck", PrivoInternal.configuration.ageGateBaseUrl.absoluteString)
        let response: AFDataResponse<AgeGateActionResponse> = await session.request(url,
                                         method: .put,
                                         parameters: data,
                                         encoder: JSONParameterEncoder.default,
                                         acceptableStatusCodes: Rest.acceptableStatusCodes,
                                         emptyResponseCodes: Rest.emptyResponsesCodes)
        if let ageEstimationError = existedAgeEstimationError(response) {
            throw ageEstimationError
        }
        return try trackPossibleAFErrorAndReturn(response)
    }
    
    func processLinkUser(data: LinkUserStatusRecord) async -> AgeGateStatusResponse? {
        let url = String(format: "%@/link-user", PrivoInternal.configuration.ageGateBaseUrl.absoluteString)
        let result: AFDataResponse<AgeGateStatusResponse> = await session.request(url,
                                         method: .post,
                                         parameters: data,
                                         encoder: JSONParameterEncoder.default,
                                         acceptableStatusCodes: Rest.acceptableStatusCodes,
                                         emptyResponseCodes: Rest.emptyResponsesCodes)
        trackPossibleAFError(result.error, result.debugDescription)
        return result.value
    }
    
    func getAgeServiceSettings(serviceIdentifier: String) async throws /*(PrivoError)*/ -> AgeServiceSettings {
        guard let url = PrivoInternal.configuration.ageGateBaseUrl.appending(.settings).withQueryParam(name: "service_identifier", value: serviceIdentifier) else {
            // unreachable branch
            throw PrivoError.unknown
        }
        
        let response: AFDataResponse<AgeServiceSettings> = await session.request(url, acceptableStatusCodes: Rest.acceptableStatusCodes)
        return try trackPossibleAFErrorAndReturn(response)
    }
    
    func getAgeVerification(verificationIdentifier: String) async -> AgeVerificationTO? {
        let url = String(format: "%@/age-verification?verification_identifier=%@", PrivoInternal.configuration.ageVerificationBaseUrl.absoluteString, verificationIdentifier)
        let result: AFDataResponse<AgeVerificationTO> = await session.request(url, acceptableStatusCodes: Rest.acceptableStatusCodes)
        trackPossibleAFError(result.error, result.debugDescription)
        return result.value
    }
    
    func generateFingerprint(fingerprint: DeviceFingerprint) async throws /*(PrivoError)*/ -> DeviceFingerprintResponse {
        let url = PrivoInternal.configuration.authBaseUrl.appending(.api).appending(.v1_0).appending(.fingerprint)
        let response: AFDataResponse<DeviceFingerprintResponse> = await session.request(
            url,
            method: .post,
            parameters:
            fingerprint,
            encoder: JSONParameterEncoder.default,
            acceptableStatusCodes: Rest.acceptableStatusCodes
        )
        return try trackPossibleAFErrorAndReturn(response)
    }
    
    //MARK: - Private functions
    
    private func existedAgeEstimationError<T:Decodable>(_ response: AFDataResponse<T>) -> CustomServerErrorResponse? {
        guard let data = response.data,
              let customServiceError = try? JSONDecoder().decode(CustomServerErrorResponse.self, from: data),
              customServiceError.code == CustomServerErrorResponse.AGE_ESTIMATION_ERROR else { return nil }
        return customServiceError
    }

}
