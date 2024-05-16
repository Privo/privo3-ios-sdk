import Foundation

struct RegisterResponse: Decodable {
    let to: To

    struct To: Decodable {
        struct ConnectedProfile: Decodable {
            let serviceId: String
            let updatePasswordLink: URL
        }
        
        let connectedProfiles: [ConnectedProfile]
    }
}
