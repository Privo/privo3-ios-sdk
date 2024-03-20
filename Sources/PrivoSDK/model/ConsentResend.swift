import Foundation

struct ConsentResendRequest: Encodable {
    let requesterServiceId: String
    let approverServiceId: String
    let email: String
}

struct ConsentResendResponse: Decodable {
    let status: ConsentResendStatus
}

struct ConsentResendStatus: Decodable {
}
