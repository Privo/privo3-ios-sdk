import Foundation

struct AnalyticEventErrorData: Encodable {
    let errorMessage: String?
    let errorCode: Int?
    let privoSettings: PrivoSettings?
}

struct AnalyticEvent: Encodable {
    let serviceIdentifier: String?
    let data: String?
    var sid: String? = nil
    var tid: String? = nil
    var svc = 62 // PrivoIosSDK
    var event = 299 // MetricUnexpectedError
}


extension AnalyticEvent {
    
    init<T:Encodable>(serviceIdentifier: String?, data: T) {
        let stringData = data.convertToString()
        self.init(serviceIdentifier: serviceIdentifier, data: stringData)
    }
    
}
