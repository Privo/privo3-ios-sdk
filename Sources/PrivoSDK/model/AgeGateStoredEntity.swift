import Foundation

struct AgeGateStoredEntity: Encodable, Decodable, Hashable {
    let userIdentifier: String?
    let nickname: String?
    let agId: String;
}
