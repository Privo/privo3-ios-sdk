//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 31.08.2021.
//

import Foundation

struct AnalyticEventErrorData : Encodable {
    let errorMessage: String?
    let response: String?
    let errorCode: Int?
    let privoSettings: PrivoSettings?;
}


struct AnalyticEvent : Encodable {
    let serviceIdentifier: String?
    let data: String?
    var sid: String? = nil
    var tid: String? = nil
    var svc = 62 // PrivoIosSDK
    var event = 299 // MetricUnexpectedError
}

// conforms Decodable for test purposes
extension AnalyticEventErrorData: Decodable {}
extension AnalyticEvent: Decodable {}
