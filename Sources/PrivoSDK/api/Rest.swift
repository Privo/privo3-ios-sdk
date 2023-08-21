//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.06.2021.
//

import Alamofire
import Foundation

class Rest {
    func getValueFromTMPStorage(key: String, completionHandler: @escaping (TmpStorageString?) -> Void) {
        var tmpStorageURL = PrivoInternal.configuration.helperUrl
        tmpStorageURL.appendPathComponent("storage")
        tmpStorageURL.appendPathComponent(key)
        AF.request(tmpStorageURL).responseDecodable(of: TmpStorageString.self) { response in
            self.trackPossibleAFError(response.error, response.response?.statusCode)
            completionHandler(response.value)
        }
    }
    func addValueToTMPStorage(value: String, ttl: Int? = nil, completionHandler: ((String?) -> Void)? = nil) {
        var tmpStorageURL = PrivoInternal.configuration.helperUrl
        tmpStorageURL.appendPathComponent("storage")
        tmpStorageURL.appendPathComponent("put")
        let data = TmpStorageString(data: value, ttl: ttl)
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
    func getServiceInfo(serviceIdentifier: String, completionHandler: @escaping (ServiceInfo?) -> Void) {
        let url = String(format: "%@/info/svc?service_identifier=%@", PrivoInternal.configuration.authBaseUrl.absoluteString, serviceIdentifier)
        AF.request(url).responseDecodable(of: ServiceInfo.self) { r in
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            completionHandler(r.value)
        }
    }
    func getAuthSessionId(completionHandler: @escaping (String?) -> Void) {
        let authStartUrl = PrivoInternal.configuration.authStartUrl
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
        let loginUrl = String(format: "%@/privo/login/token?session_id=%@", PrivoInternal.configuration.authBaseUrl.absoluteString,sessionId)
        AF.request(loginUrl, method: .post, parameters: nil, encoding: BodyStringEncoding(body: oldToken)).responseDecodable(of: LoginResponse.self) { r in
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            let token = r.value?.token
            completionHandler(token)
        }
    }
    func processStatus(data: StatusRecord, completionHandler: @escaping (AgeGateStatusResponse?) -> Void) {
        let url = String(format: "%@/status", PrivoInternal.configuration.ageGateBaseUrl.absoluteString)
        AF.request(url, method: .put, parameters: data, encoder: JSONParameterEncoder.default).responseDecodable(of: AgeGateStatusResponse.self, emptyResponseCodes: [200, 204, 205] ) { r in
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            completionHandler(r.value)
        }
    }
    func processBirthDate(data: FpStatusRecord,
                          completionHandler: @escaping (AgeGateActionResponse?) -> Void,
                          ageEstimationHandler: @escaping (CustomServerErrorResponse) -> Void) {
        let url = String(format: "%@/birthdate", PrivoInternal.configuration.ageGateBaseUrl.absoluteString)
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
        let url = String(format: "%@/recheck", PrivoInternal.configuration.ageGateBaseUrl.absoluteString)
        AF.request(url, method: .put, parameters: data, encoder: JSONParameterEncoder.default).responseDecodable(of: AgeGateActionResponse.self, emptyResponseCodes: [200, 204, 205] ) { [weak self] r in
            guard let self = self else { return }
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            guard let ageEstimationError = self.existedAgeEstimationError(r) else { completionHandler(r.value); return }
            ageEstimationHandler(ageEstimationError)
        }
    }
    func processLinkUser(data: LinkUserStatusRecord, completionHandler: @escaping (AgeGateStatusResponse?) -> Void) {
        let url = String(format: "%@/link-user", PrivoInternal.configuration.ageGateBaseUrl.absoluteString)
        AF.request(url, method: .post, parameters: data, encoder: JSONParameterEncoder.default).responseDecodable(of: AgeGateStatusResponse.self, emptyResponseCodes: [200, 204, 205] ) { r in
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            completionHandler(r.value)
        }
    }
    func getAgeServiceSettings(serviceIdentifier: String, completionHandler: @escaping (AgeServiceSettings?) -> Void) {
        let url = String(format: "%@/settings?service_identifier=%@", PrivoInternal.configuration.ageGateBaseUrl.absoluteString, serviceIdentifier)
        AF.request(url).responseDecodable(of: AgeServiceSettings.self) { r in
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            completionHandler(r.value)
        }
    }
    func getAgeVerification(verificationIdentifier: String, completionHandler: @escaping (AgeVerificationTO?) -> Void) {
        let url = String(format: "%@/age-verification?verification_identifier=%@", PrivoInternal.configuration.ageVerificationBaseUrl.absoluteString, verificationIdentifier)
        AF.request(url).responseDecodable(of: AgeVerificationTO.self) { r in
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            completionHandler(r.value)
        }
    }
    func generateFingerprint(fingerprint: DeviceFingerprint, completionHandler: @escaping (DeviceFingerprintResponse?) -> Void) {
        let url = String(format: "%@/fp", PrivoInternal.configuration.authBaseUrl.absoluteString)
        AF.request(url, method: .post, parameters: fingerprint, encoder: JSONParameterEncoder.default).responseDecodable(of: DeviceFingerprintResponse.self ) { r in
            self.trackPossibleAFError(r.error, r.response?.statusCode)
            completionHandler(r.value)
        }
    }
    func trackCustomError(_ errorDescr: String) {
        let settings = PrivoInternal.settings;
        let data = AnalyticEventErrorData(errorMessage: errorDescr, errorCode: nil, privoSettings: settings)
        
        if let jsonData = try? JSONEncoder().encode(data) {
            let jsonString = String(decoding: jsonData, as: UTF8.self)
            let event = AnalyticEvent(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, data: jsonString)
            sendAnalyticEvent(event)
        }
    }
    func trackPossibleAFError(_ error: AFError?, _ code: Int?) {
        if (code != 200 && code != 204 && code != 205) {
            if let error = error {
                let data = AnalyticEventErrorData(errorMessage: error.errorDescription, errorCode: error.responseCode, privoSettings: nil)
                if let jsonData = try? JSONEncoder().encode(data) {
                    let jsonString = String(decoding: jsonData, as: UTF8.self)
                    let event = AnalyticEvent(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, data: jsonString)
                    sendAnalyticEvent(event)
                }
            }
        }
    }
    func sendAnalyticEvent(_ event: AnalyticEvent) {
        var metricsURL = PrivoInternal.configuration.helperUrl
        metricsURL.appendPathComponent("metrics")
        AF.request(metricsURL, method: .post, parameters: event, encoder: JSONParameterEncoder.default).response {r in
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
    
    private func existedAgeEstimationError<T:Decodable>(_ response: DataResponse<T,AFError>) -> CustomServerErrorResponse? {
        guard response.response?.statusCode == 500,
              let data = response.data,
              let customServiceError = try? JSONDecoder().decode(CustomServerErrorResponse.self, from: data),
              customServiceError.code == CustomServerErrorResponse.AGE_ESTIMATION_ERROR else { return nil }
        return customServiceError
    }

}
