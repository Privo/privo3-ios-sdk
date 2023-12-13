import Foundation
import Alamofire

extension Session {
    
    func request<T:Decodable,P:Encodable>(_ url: URLConvertible,
                                          method: HTTPMethod = .get,
                                          parameters: P?,
                                          encoder: ParameterEncoder,
                                          emptyResponseCodes: Set<Int> = DecodableResponseSerializer<Int>.defaultEmptyResponseCodes) async -> AFDataResponse<T> {
        return await withCheckedContinuation { promise in
            request(url, method: method, parameters: parameters, encoder: encoder)
                .responseDecodable(of: T.self, emptyResponseCodes: emptyResponseCodes) {
                promise.resume(returning: $0)
            }
        }
    }
    
    func request<T:Decodable>(_ url: URLConvertible,
                              method: HTTPMethod = .get,
                              encoding: ParameterEncoding = URLEncoding.default,
                              emptyResponseCodes: Set<Int> = DecodableResponseSerializer<Int>.defaultEmptyResponseCodes) async -> AFDataResponse<T> {
      return await withCheckedContinuation { promise in
          request(url, method: method, encoding: encoding)
              .responseDecodable(of: T.self, emptyResponseCodes: emptyResponseCodes) {
                  promise.resume(returning: $0)
              }
      }
    }
    
    func request(_ url: URLConvertible) async -> AFDataResponse<Data?> {
        return await withCheckedContinuation{ promise in
            request(url)
                .response() {
                    promise.resume(returning: $0)
                }
        }
    }
    
}
