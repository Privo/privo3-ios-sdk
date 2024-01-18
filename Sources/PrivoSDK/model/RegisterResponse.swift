import Foundation

struct RegisterResponse: Codable {
    let to: To

    struct To: Codable {
        let serviceId: String
        let fullyRegistered: Bool
        let roleIdentifier: String
        let emailMeta: EmailMeta
        let locale: String
        let verificationTier: VerificationTier
        let features: [Feature]
        let pin: String
        let consentMeta: ConsentMeta
        let connectedProfiles: [String]
        let updatePasswordLink: String

        struct EmailMeta: Codable {
            let email: String
            //let emailStatus: [String: Any] // Adjust the type accordingly

//            enum CodingKeys: String, CodingKey {
//                case email
//                case emailStatus = "email_status"
//            }
        }

        struct VerificationTier: Codable {
            // Define properties as needed
        }

        struct Feature: Codable {
            let consentDate: Int
            let on: Bool
            let featureIdentifier: String
            let category: String
            let active: Bool

            enum CodingKeys: String, CodingKey {
                case consentDate = "consent_date"
                case on
                case featureIdentifier = "feature_identifier"
                case category
                case active
            }
        }

        struct ConsentMeta: Codable {
            let consentURL: String
            let consentRequests: [ConsentRequest]

            enum CodingKeys: String, CodingKey {
                case consentURL = "consent_url"
                case consentRequests = "consent_requests"
            }
        }

        struct ConsentRequest: Codable {
            let status: String
            let consentDate: Int

            enum CodingKeys: String, CodingKey {
                case status
                case consentDate = "consent_date"
            }
        }
    }
}
