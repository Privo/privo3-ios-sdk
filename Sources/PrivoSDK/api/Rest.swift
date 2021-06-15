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
        var tmpStorageURL = PrivoInternal.configuration.tmpStorageUrl
        tmpStorageURL.appendPathComponent(key)
        AF.request(tmpStorageURL).responseDecodable(of: TmpStorageString.self) { response in
            completionHandler(response.value)
        }
    }
    func addValueToTMPStorage(value: String, ttl: Int? = nil, completionHandler: ((String?) -> Void)? = nil) {
        let tmpStorageURL = PrivoInternal.configuration.tmpStorageUrl
        let data = TmpStorageString(data: value, ttl: ttl)
        AF.request(tmpStorageURL, method: .post, parameters: data, encoder: JSONParameterEncoder.default).responseDecodable(of: TmpStorageResponse.self) { response in
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
    func getAuthSessionId(completionHandler: @escaping (String?) -> Void) {
        let authStartUrl = PrivoInternal.configuration.authStartUrl
        let sessionIdKey = "session_id"
        AF.request(authStartUrl).response() { r in
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
        let loginUrl = String(format: "%@/login/token?session_id=%@", PrivoInternal.configuration.authBaseUrl.absoluteString,sessionId)
        AF.request(loginUrl, method: .post, parameters: nil, encoding: BodyStringEncoding(body: oldToken)).responseDecodable(of: LoginResponse.self) { r in
            let token = r.value?.token
            completionHandler(token)
        }
    }

}
