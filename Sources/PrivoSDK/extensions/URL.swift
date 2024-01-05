//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

extension URL {
    // Since iOS16 min support version use URL.appending(queryItems: [URLQueryItem]) -> URL
    func withQueryParam(name: String, value: String?) -> URL {
        let queryItem = URLQueryItem(name: name, value: value)
        
        if #available(iOS 16, *) {
            return appending(queryItems: [queryItem])
        } else {
            if var urlComponents = URLComponents(string: self.absoluteString),
               var queryItems: [URLQueryItem] = urlComponents.queryItems
            {
                queryItems.append(queryItem)
                urlComponents.queryItems = queryItems
                if let updatedURL = urlComponents.url {
                    return updatedURL
                } else {
                    // unreachable branch
                    return self
                }
            } else {
                // unreachable branch
                return self
            }
        }
    }
    
    func withPath(_ value: String) -> URL  {
        let nextString = absoluteString + value
        if let updatedURL = URL(string: nextString) {
            return updatedURL
        } else {
            // unreachable branch
            return self
        }
    }
    
    mutating func append(_ pathComponents: [String]) -> URL {
        pathComponents.forEach { self = appendingPathComponent($0) }
        return self
    }
    
    func urlComponent(resolvingAgainstBaseURL: Bool = true) -> URLComponents {
        return URLComponents(url: self, resolvingAgainstBaseURL: resolvingAgainstBaseURL)!
    }
    
}
