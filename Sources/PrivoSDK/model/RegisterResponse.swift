import Foundation

struct RegisterResponse: Decodable {
    let to: To

    struct To: Decodable {
        let updatePasswordLink: String
    }
}
