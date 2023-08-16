import Foundation

struct AgeVerificationEventInternal: Codable {
   let status: AgeVerificationStatusInternal
   let profile: AgeVerificationProfile?
   let ageVerificationId: String?
}
