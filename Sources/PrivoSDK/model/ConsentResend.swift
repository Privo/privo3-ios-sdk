import Foundation

struct ConsentResendRequest: Encodable {
    let requesterServiceId: String
    let approverServiceId: String
    let email: String
}

struct ConsentResendResponse: Decodable {
    let status: Status
}

struct Status: Decodable {
}
