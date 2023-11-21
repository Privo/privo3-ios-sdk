//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.06.2021.
//

public struct PrivoSettings: Encodable {
    public let serviceIdentifier: String
    public let envType: EnviromentType
    public let apiKey: String?
    public init(serviceIdentifier: String, envType: EnviromentType, apiKey: String? = nil) {
        self.serviceIdentifier = serviceIdentifier
        self.envType = envType
        self.apiKey = apiKey
    }
}

// conforms Decodable for test purposes
extension PrivoSettings: Decodable {}
