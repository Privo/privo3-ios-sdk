import Foundation

struct LoginResponse: Decodable {
    let token: String?
    let status: LoginStatusTO
    let actions: [LoginActionTO]?
    let error: AppError?
}
