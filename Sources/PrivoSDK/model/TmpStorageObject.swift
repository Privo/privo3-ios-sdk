import Foundation

struct TmpStorageString: Decodable, Encodable {
    let data: String
    let ttl: Int?
}
struct TmpStorageResponse: Decodable {
    let id: String
}

