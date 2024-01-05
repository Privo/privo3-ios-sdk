//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
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
