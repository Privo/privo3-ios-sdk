import Foundation

struct ServiceInfoResponse: Decodable {
    let serviceIdentifier: String
    let apiKeys: [String]?
    let authMethods: [Int]?
    let p2siteId: Int?
}
