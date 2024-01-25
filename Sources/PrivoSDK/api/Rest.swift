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
    static let analytic: Self = "metrics"
    static let status: Self = "status"
    static let api: Self = "api"
    static let v1_0: Self = "v1.0"
    static let fingerprint: Self = "fp"
    static let settings: Self = "settings"
    static let account: Self = "account"
    static let parent: Self = "parent"
    static let oauth: Self = "oauth"
    static let token: Self = "token"
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
    
    func processStatus(data: StatusRecord) async throws -> AgeGateStatusResponse
    func generateFingerprint(fingerprint: DeviceFingerprint) async throws -> DeviceFingerprintResponse
    func getAuthSessionId() async -> String?
    func renewToken(oldToken: String, sessionId: String) async -> String?
    func getAgeServiceSettings(serviceIdentifier: String) async throws -> AgeServiceSettings
    func getAgeVerification(verificationIdentifier: String) async -> AgeVerificationTO?
    func processLinkUser(data: LinkUserStatusRecord) async throws -> AgeGateStatusResponse
    func processBirthDate(data: FpStatusRecord) async throws -> AgeGateActionResponse
    func processRecheck(data: RecheckStatusRecord) async throws -> AgeGateActionResponse
    func trackCustomError(_ errorDescr: String)
    func sendAnalyticEvent(_ event: AnalyticEvent)
    func registerParentAndChild(_ parentChildPair: ParentChildPair, _ token: String) async throws -> RegisterResponse
    func getP3Token(_ clientId: String, _ clientSecret: String) async throws -> TokenResponse
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
    private static let emptyResponsesCodes: Set<Int> = acceptableStatusCodes
    
    private let urlConfig: URLSessionConfiguration
    private let session: Session
    
    //MARK: - Internal functions
    
    func getValueFromTMPStorage(key: String, completionHandler: @escaping (TmpStorageString?) -> Void) {
        Task.init {
            let result = await getValueFromTMPStorage(key: key)
            completionHandler(result)
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
            trackPossibleAFError(error, description)
            
            switch error {
            case let .sessionTaskFailed(error: error):
                let nserror = error as NSError
                switch nserror.code {
                case NSURLErrorNotConnectedToInternet:
                    throw PrivoError.noInternetConnection
                case NSURLErrorCancelled:
                    throw PrivoError.cancelled
                default:
                    throw PrivoError.networkConnectionProblem(nserror)
                }
            case .explicitlyCancelled:
                throw PrivoError.cancelled
                
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
    
    func processStatus(data: StatusRecord) async throws /*(PrivoError)*/ -> AgeGateStatusResponse {
        let url = PrivoInternal.configuration.ageGateBaseUrl.appending(.status)
        let response: AFDataResponse<AgeGateStatusResponse> = await session.request(
            url.absoluteString,
            method: .put,
            parameters: data,
            encoder: JSONParameterEncoder.default,
            acceptableStatusCodes: Rest.acceptableStatusCodes,
            emptyResponseCodes: Rest.emptyResponsesCodes
        )
        return try trackPossibleAFErrorAndReturn(response)
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
    
    func processLinkUser(data: LinkUserStatusRecord) async throws /*(Privo)*/ -> AgeGateStatusResponse {
        let url = String(format: "%@/link-user", PrivoInternal.configuration.ageGateBaseUrl.absoluteString)
        let response: AFDataResponse<AgeGateStatusResponse> = await session.request(
            url,
            method: .post,
            parameters: data,
            encoder: JSONParameterEncoder.default,
            acceptableStatusCodes: Rest.acceptableStatusCodes,
            emptyResponseCodes: Rest.emptyResponsesCodes
        )
        return try trackPossibleAFErrorAndReturn(response)
    }
    
    func getAgeServiceSettings(serviceIdentifier: String) async throws /*(PrivoError)*/ -> AgeServiceSettings {
        let url = PrivoInternal.configuration.ageGateBaseUrl.appending(.settings).withQueryParam(name: "service_identifier", value: serviceIdentifier)
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
    
    func getP3Token(_ clientId: String, _ clientSecret: String) async throws /*(PrivoError)*/ -> TokenResponse {
        let clientData = OAuthToken(client_id: clientId, client_secret: clientSecret)
        
        let url = PrivoInternal.configuration.privohubUrl
            .appending(.oauth)
            .appending(.token)
            .withQueryItems(clientData.toQueryItems())
        
        let response: AFDataResponse<TokenResponse> = await
        session.request(
            url,
            method: .post,
            acceptableStatusCodes: Rest.acceptableStatusCodes
        )
        
        return try trackPossibleAFErrorAndReturn(response)
    }
    
    func registerParentAndChild(_ parentChildPair: ParentChildPair, _ token: String) async throws /*(PrivoError)*/ -> RegisterResponse {
        let url = PrivoInternal.configuration.svcUrl.appending(.api).appending(.v1_0).appending(.account).appending(.parent)
        let response: AFDataResponse<RegisterResponse> = await session.request(
            url,
            method: .post,
            parameters: parentChildPair,
            encoder: JSONParameterEncoder.convertToSnakeCase,
            headers: HTTPHeaders(arrayLiteral: .init(name: "Authorization", value: "Bearer \(token)")),
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
