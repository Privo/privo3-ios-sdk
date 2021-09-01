//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 15.06.2021.
//

struct VerificationConfig: Encodable {
    let apiKey: String
    let siteIdentifier: String
    let displayMode = "redirect"
    let transparentBackground = true
}
