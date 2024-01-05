//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
import Alamofire

extension Session {
    
    func request<T:Decodable,P:Encodable>(_ url: URLConvertible,
                                          method: HTTPMethod = .get,
                                          parameters: P?,
                                          encoder: ParameterEncoder,
                                          acceptableStatusCodes: Set<Int>,
                                          emptyResponseCodes: Set<Int> = DecodableResponseSerializer<Int>.defaultEmptyResponseCodes) async -> AFDataResponse<T> {
        let r = request(url, method: method, parameters: parameters, encoder: encoder)
            .validate(statusCode: acceptableStatusCodes)
        
        return await withTaskCancellationHandler {
            return await withCheckedContinuation { promise in
                r.responseDecodable(of: T.self, emptyResponseCodes: emptyResponseCodes) {
                    promise.resume(returning: $0)
                }
            }
        } onCancel: {
            r.cancel()
        }
    }
    
    func request<T:Decodable>(_ url: URLConvertible,
                              method: HTTPMethod = .get,
                              encoding: ParameterEncoding = URLEncoding.default,
                              acceptableStatusCodes: Set<Int>,
                              emptyResponseCodes: Set<Int> = DecodableResponseSerializer<Int>.defaultEmptyResponseCodes) async -> AFDataResponse<T> {
        let r = request(url, method: method, encoding: encoding)
            .validate(statusCode: acceptableStatusCodes)
        
        return await withTaskCancellationHandler {
            return await withCheckedContinuation { promise in
                r.responseDecodable(of: T.self, emptyResponseCodes: emptyResponseCodes) {
                    promise.resume(returning: $0)
                }
            }
        } onCancel: {
            r.cancel()
        }
    }
    
    func request(_ url: URLConvertible, acceptableStatusCodes: Set<Int>) async -> AFDataResponse<Data?> {
        let r = request(url)
            .validate(statusCode: acceptableStatusCodes)
        
        return await withTaskCancellationHandler {
            return await withCheckedContinuation{ promise in
                r.response() {
                    promise.resume(returning: $0)
                }
            }
        } onCancel: {
            r.cancel()
        }
    }
}
