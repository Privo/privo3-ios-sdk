import Foundation

struct LoginResponse: Decodable {
    let token: String?
    let status: LoginStatus
    let actions: [LoginAction]?
    let error: AppError?
}
