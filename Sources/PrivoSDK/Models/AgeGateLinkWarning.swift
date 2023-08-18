import Foundation

struct AgeGateLinkWarning: Encodable {
    let description: String
    let agIdEntities: Set<AgeGateStoredEntity>
}
