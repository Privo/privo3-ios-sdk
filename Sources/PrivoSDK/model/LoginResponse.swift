//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

enum AType: String, Codable {
    case Redirect
    case FormSubmit
    case NewWindow
    case Data
}
enum AVType: String, Codable {
    case Button
    case Link
    case NewWindow
    case Data
}

struct LoginResponseAction: Decodable {
    let aType: AType
    let targetUrl: String
    let isAutoRun: Bool
    let view: AVType?
}

struct LoginResponse: Decodable {
    let token: String?
    let status: LoginResponseStatus
    let actions: Array<LoginResponseAction>?
    let error: AppError?
}
