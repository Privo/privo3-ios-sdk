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
