//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.06.2021.
//
import Foundation

class Configuration {
    let type: EnviromentType
    let authUrl: URL
    let tmpStorageUrl: URL
    init (type: EnviromentType) {
        self.type = type
        switch type {
        case .Local:
            self.authUrl = URL(string: "https://auth-dev.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=")!
            self.tmpStorageUrl = URL(string: "https://helper-svc-dev.privo.com/rest/api/v1.0/storage")!
        case .Dev:
            self.authUrl = URL(string: "https://auth-dev.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=")!
            self.tmpStorageUrl = URL(string: "https://helper-svc-dev.privo.com/rest/api/v1.0/storage")!
        case .Int:
            self.authUrl = URL(string: "https://auth-int.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=")!
            self.tmpStorageUrl = URL(string: "https://helper-svc-int.privo.com/rest/api/v1.0/storage")!
        case .Test:
            self.authUrl = URL(string: "https://auth-test.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=")!
            self.tmpStorageUrl = URL(string: "https://helper-svc-test.privo.com/rest/api/v1.0/storage")!
        case .Prod:
            self.authUrl = URL(string: "https://auth.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=")!
            self.tmpStorageUrl = URL(string: "https://helper-svc.privo.com/rest/api/v1.0/storage")!
        }
    }
    
}
