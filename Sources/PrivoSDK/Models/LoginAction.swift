import Foundation

struct LoginAction: Decodable {
    let aType: AType
    let targetUrl: String
    let isAutoRun: Bool
    let view: AVType?
}
