import Foundation

struct AgeGateStoredEntity: Codable, Hashable {
    let userIdentifier: String?
    let nickname: String?
    let agId: String
}
