import Foundation

struct TmpStorageString: Decodable, Encodable {
    let data: String
    let ttl: Int?
}

