//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.06.2021.
//

public struct PrivoSettings {
    public let serviceIdentifier: String
    public let envType: EnviromentType
    public let siteIdentifier: String?
    public let apiKey: String?
    public init(serviceIdentifier: String, envType: EnviromentType, siteIdentifier: String? = nil, apiKey: String? = nil) {
        self.serviceIdentifier = serviceIdentifier
        self.envType = envType
        self.siteIdentifier = siteIdentifier
        self.apiKey = apiKey
    }
}
