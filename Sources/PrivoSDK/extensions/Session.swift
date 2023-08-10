import Foundation
import Alamofire

extension Session {
    
    func requestAsync<T:Decodable,P:Encodable>(_ url: URLConvertible,
                                               method: HTTPMethod = .get,
                                               parameters: P? = nil,
                                               emptyResponseCodes: Set<Int> = DecodableResponseSerializer<Int>.defaultEmptyResponseCodes) async -> DataResponse<T,AFError> {
        return await withCheckedContinuation { promise in
            request(url, method: method, parameters: parameters)
                .responseDecodable(of: T.self, emptyResponseCodes: emptyResponseCodes) {
                promise.resume(returning: $0)
            }
        }
    }
    
    func requestAsync<T:Decodable>(_ url: URLConvertible,
                                   method: HTTPMethod = .get,
                                   emptyResponseCodes: Set<Int> = DecodableResponseSerializer<Int>.defaultEmptyResponseCodes) async -> DataResponse<T,AFError> {
      return await withCheckedContinuation { promise in
          request(url, method: method)
              .responseDecodable(of: T.self, emptyResponseCodes: emptyResponseCodes) {
              promise.resume(returning: $0)
          }
      }
    }
    
    func requestAsync<T:Decodable>(_ url: URLConvertible,
                                   method: HTTPMethod = .get,
                                   encoding: ParameterEncoding) async -> DataResponse<T,AFError> {
        return await withCheckedContinuation { promise in
            request(url, method: method, encoding: encoding)
                .responseDecodable(of: T.self) { promise.resume(returning: $0) }
        }
    }
    
    func requestAsync(_ url: URLConvertible) async -> AFDataResponse<Data?> {
        return await withCheckedContinuation{ promise in
            request(url).response() { promise.resume(returning: $0) }
        }
    }
    
    func requestAsync<T:Decodable,
                      P:Encodable>(_ url: URLConvertible,
                                   method: HTTPMethod = .get,
                                   parameter: P? = nil,
                                   encoder: ParameterEncoder = URLEncodedFormParameterEncoder.default,
                                   emptyResponseCodes: Set<Int> = DecodableResponseSerializer<Int>.defaultEmptyResponseCodes) async -> DataResponse<T,AFError> {
        return await withCheckedContinuation { promise in
            request(url, method: method, parameters: parameter, encoder: encoder)
                .responseDecodable(of: T.self, emptyResponseCodes: emptyResponseCodes) {
                    promise.resume(returning: $0)
                }
        }
    }
    
}
