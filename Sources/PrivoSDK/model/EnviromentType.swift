//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.06.2021.
//

public enum EnviromentType: Int, Equatable, CaseIterable, Encodable {
    case Local = 0
    case Dev
    case Int
    case Test
    case Prod
}

// conforms Decodable for test purposes
extension EnviromentType: Decodable {}
