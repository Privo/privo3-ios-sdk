import Foundation

struct AnalyticEventErrorData: Encodable {
    let errorMessage: String?
    let errorCode: Int?
    let privoSettings: PrivoSettings?
}
