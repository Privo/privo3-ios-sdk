import Foundation

struct StatusRecord: Codable, Hashable {
    let serviceIdentifier: String
    let fpId: String
    let agId: String?
    let extUserId: String?
}
