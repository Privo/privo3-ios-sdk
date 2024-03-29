import Foundation

struct ServiceInfo: Decodable {
    let serviceIdentifier: String
    let apiKeys: Array<String>?
    let authMethods: Array<Int>?
    let p2siteId: Int?
}
