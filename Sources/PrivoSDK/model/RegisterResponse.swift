import Foundation

struct RegisterResponse: Codable {
    let to: To

    struct To: Codable {
        let updatePasswordLink: String
    }
}
