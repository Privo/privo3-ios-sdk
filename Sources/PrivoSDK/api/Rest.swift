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
        var tmpStorageURL = PrivoInternal.shared.configuration.tmpStorageUrl
        tmpStorageURL.appendPathComponent(key)
        AF.request(tmpStorageURL).responseDecodable(of: TmpStorageString.self) { response in
            completionHandler(response.value)
        }
    }
    func getAuthSessionId(completionHandler: @escaping (String?) -> Void) {
        let authStartUrl = PrivoInternal.shared.configuration.authStartUrl
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
        let loginUrl = String(format: "%@/privo/login/token?session_id=%@", PrivoInternal.shared.configuration.authBaseUrl.absoluteString,sessionId)
        AF.request(loginUrl, method: .post, parameters: oldToken).responseDecodable(of: LoginResponse.self) { r in
            let token = r.value?.token
            completionHandler(token)
        }
    }

}
