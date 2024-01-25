import Foundation

struct ParentChildPair: Codable {
    let roleIdentifier: String
    let email: String
    let minorRegistrations: [MinorRegistration]
    
    struct MinorRegistration: Codable {
        let firstName: String
        let lastName: String
        let birthDateYYYYMMDD: String
        let sendParentEmail: Bool
        let roleIdentifier: String
        let sendCongratulationsEmail: Bool
        let attributes: [Attribute]
        let userName: String
    }
    
    struct Attribute: Codable {
        let name: String
        let value: String
    }
}
