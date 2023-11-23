//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 09.06.2021.
//

import Alamofire
import Foundation


func checkNetwork() throws {
    let rManager = NetworkReachabilityManager()
    if (rManager?.isReachable == false) {
        throw PrivoError.noInternetConnection
    }
}

struct BodyStringEncoding: ParameterEncoding {

    //MARK: - Private properties
    
    private let body: String

    //MARK: - Internal initialisers
    
    init(body: String) { self.body = body }
    
    //MARK: - Internal functions

    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        guard var urlRequest = urlRequest.urlRequest else { throw Errors.emptyURLRequest }
        guard let data = body.data(using: .utf8) else { throw Errors.encodingProblem }
        urlRequest.httpBody = data
        return urlRequest
    }
    
}

extension BodyStringEncoding {
    enum Errors: Error, LocalizedError{
        case emptyURLRequest
        case encodingProblem
        
        var errorDescription: String? {
            switch self {
                case .emptyURLRequest: return "Empty url request"
                case .encodingProblem: return "Encoding problem"
            }
        }
    }
}
