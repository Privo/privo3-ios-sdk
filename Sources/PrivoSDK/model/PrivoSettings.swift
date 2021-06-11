//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.06.2021.
//

public struct PrivoSettings {
    public let serviceIdentifier: String
    public let envType: EnviromentType
    public let siteId: String?
    public init(serviceIdentifier: String, envType: EnviromentType, siteId: String? = nil) {
        self.serviceIdentifier = serviceIdentifier
        self.envType = envType
        self.siteId = siteId
    }
}
