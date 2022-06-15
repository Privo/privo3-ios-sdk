//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 13.06.2022.
//

import Foundation


public struct AgeVerificationProfile : Encodable, Decodable {
    let userIdentifier: String?;
    let ageGateIdentifier: String?; // for internal usage.
    let firstName: String?;
    let email: String?;
    let birthDateYYYYMMDD: String?; // "yyyy-MM-dd" format
    let phoneNumber: String?; // in the full international format (E.164, e.g. “+17024181234”)
}
