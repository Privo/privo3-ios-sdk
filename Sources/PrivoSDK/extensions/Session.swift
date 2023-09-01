import Foundation
import Alamofire

extension Session {
    
    func request<T:Decodable,P:Encodable>(_ url: URLConvertible,
                                          method: HTTPMethod = .get,
                                          parameters: P? = nil,
                                          encoder: ParameterEncoder = URLEncodedFormParameterEncoder.default,
                                          emptyResponseCodes: Set<Int> = DecodableResponseSerializer<Int>.defaultEmptyResponseCodes) async -> DataResponse<T,AFError> {
        return await withCheckedContinuation { promise in
            request(url, method: method, parameters: parameters, encoder: encoder)
                .responseDecodable(of: T.self, emptyResponseCodes: emptyResponseCodes) {
                promise.resume(returning: $0)
            }
        }
    }
    
    func request<T:Decodable>(_ url: URLConvertible,
                                   method: HTTPMethod = .get,
                                   emptyResponseCodes: Set<Int> = DecodableResponseSerializer<Int>.defaultEmptyResponseCodes) async -> DataResponse<T,AFError> {
      return await withCheckedContinuation { promise in
          request(url, method: method)
              .responseDecodable(of: T.self, emptyResponseCodes: emptyResponseCodes) {
              promise.resume(returning: $0)
          }
      }
    }
    
    func request<T:Decodable>(_ url: URLConvertible,
                              method: HTTPMethod = .get,
                              encoding: ParameterEncoding) async -> DataResponse<T,AFError> {
        return await withCheckedContinuation { promise in
            request(url, method: method, encoding: encoding)
                .responseDecodable(of: T.self) { promise.resume(returning: $0) }
        }
    }
    
    func request(_ url: URLConvertible) async -> AFDataResponse<Data?> {
        return await withCheckedContinuation{ promise in
            request(url).response() { promise.resume(returning: $0) }
        }
    }
    
    func request<T:Decodable,
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
