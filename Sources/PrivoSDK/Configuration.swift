//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.06.2021.
//
import Foundation

class Configuration {
    let type: EnviromentType
    let authBaseUrl: URL
    let authStartUrl: URL
    let verificationUrl: URL
    let tmpStorageUrl: URL
    let lgsRegistrationUrl: URL
    let tokenStorageKey: String
    init (type: EnviromentType) {
        self.type = type
        switch type {
        case .Local:
            self.authBaseUrl = URL(string: "https://auth-dev.privo.com/api/v1.0/privo")!
            self.authStartUrl = URL(string: "https://auth-dev.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=")!
            self.verificationUrl = URL(string: "https://verification-dev.privo.com/vw")!
            self.tmpStorageUrl = URL(string: "https://helper-svc-dev.privo.com/rest/api/v1.0/storage")!
            self.lgsRegistrationUrl = URL(string: "https://privohub-dev.privo.com/lgs")!
            self.tokenStorageKey = "privo-token-local"
        case .Dev:
            self.authBaseUrl = URL(string: "https://auth-dev.privo.com/api/v1.0/privo")!
            self.authStartUrl = URL(string: "https://auth-dev.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=")!
            self.verificationUrl = URL(string: "https://verification-dev.privo.com/vw")!
            self.tmpStorageUrl = URL(string: "https://helper-svc-dev.privo.com/rest/api/v1.0/storage")!
            self.lgsRegistrationUrl = URL(string: "https://privohub-dev.privo.com/lgs")!
            self.tokenStorageKey = "privo-token-dev"
        case .Int:
            self.authBaseUrl = URL(string: "https://auth-int.privo.com/api/v1.0/privo")!
            self.authStartUrl = URL(string: "https://auth-int.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=")!
            self.verificationUrl = URL(string: "https://verification-int.privo.com/vw")!
            self.tmpStorageUrl = URL(string: "https://helper-svc-int.privo.com/rest/api/v1.0/storage")!
            self.lgsRegistrationUrl = URL(string: "https://privohub-int.privo.com/lgs")!
            self.tokenStorageKey = "privo-token-int"
        case .Test:
            self.authBaseUrl = URL(string: "https://auth-test.privo.com/api/v1.0/privo")!
            self.authStartUrl = URL(string: "https://auth-test.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=")!
            self.verificationUrl = URL(string: "https://verification-test.privo.com/vw")!
            self.tmpStorageUrl = URL(string: "https://helper-svc-test.privo.com/rest/api/v1.0/storage")!
            self.lgsRegistrationUrl = URL(string: "https://privohub-test.privo.com/lgs")!
            self.tokenStorageKey = "privo-token-test"
        case .Prod:
            self.authBaseUrl = URL(string: "https://auth.privo.com/api/v1.0/privo")!
            self.authStartUrl = URL(string: "https://auth.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=")!
            self.verificationUrl = URL(string: "https://verification.privo.com/vw")!
            self.tmpStorageUrl = URL(string: "https://helper-svc.privo.com/rest/api/v1.0/storage")!
            self.lgsRegistrationUrl = URL(string: "https://privohub.privo.com/lgs")!
            self.tokenStorageKey = "privo-token"
        }
    }
    
}
