import Foundation

struct ParentChildPair: Codable {
    let serviceId: String
    let firstName: String
    let lastName: String
    let gender: String
    let birthDateYYYYMMDD: String
    let roleIdentifier: String
    let email: String
    let features: [Feature]
    let minorRegistrations: [MinorRegistration]
    let sendCongratulationsEmail: Bool
    let emailVerified: Bool
    let attributes: [Attribute]
    let userName: String
    let address: Address
    let locale: String
    let externalAccountIdentifier: String
    let redirectUri: String
    
    struct Feature: Codable {
        let featureIdentifier: String
    }
    
    struct MinorRegistration: Codable {
        let serviceId: String
        let firstName: String
        let lastName: String
        let gender: String
        let birthDateYYYYMMDD: String
        let sendParentEmail: Bool
        let roleIdentifier: String
        let email: String
        let emailVerified: Bool
        let sendCongratulationsEmail: Bool
        let attributes: [Attribute]
        let userName: String
        let address: Address
        let locale: String
        let externalAccountIdentifier: String
        let redirectUri: String
    }
    
    struct Attribute: Codable {
        let name: String
        let value: String
    }
    
    struct Address: Codable {
        let streetAddress1: String
        let streetAddress2: String
        let city: String
        let stateProvince: String
        let region: String
        let postalCode: String
        let country: String
    }
}
