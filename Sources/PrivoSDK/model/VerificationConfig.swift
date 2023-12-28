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
    let prompt: [String] = [AuthServerPrompt.login.rawValue]
}

enum AuthServerPrompt: String, Encodable {
    case none = "none"
    case login = "login"
    case consent = "consent"
    case select_account = "select_account"
}
