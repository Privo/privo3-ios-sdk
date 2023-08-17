import Foundation

struct LinkUserStatusRecord: Codable, Hashable {
    let serviceIdentifier: String
    let agId: String
    let extUserId: String
}
