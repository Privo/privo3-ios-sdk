import Foundation

struct LoginActionTO: Decodable {
    let aType: AType
    let targetUrl: String
    let isAutoRun: Bool
    let view: AVType?
}
