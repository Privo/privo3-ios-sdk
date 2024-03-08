import Foundation

extension URL {
    // Since iOS16 min support version use URL.appending(queryItems: [URLQueryItem]) -> URL
    func withQueryParam(name: String, value: String?) -> URL {
        let queryItem = URLQueryItem(name: name, value: value)
        return self.withQueryItems([queryItem])
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
    
    // Since iOS16 min support version use URL.appending(queryItems: [URLQueryItem]) -> URL
    func appendingQueryItems(_ queryItems: [URLQueryItem]) -> URL {
        if #available(iOS 16, *) {
            return appending(queryItems: queryItems)
        } else {
            if var urlComponents = URLComponents(string: self.absoluteString) {
                var existingQueryItems: [URLQueryItem] = urlComponents.queryItems ?? []
                existingQueryItems.append(contentsOf: queryItems)
                urlComponents.queryItems = existingQueryItems
                if let updatedURL = urlComponents.url {
                    return updatedURL
                } else {
                    // unreachable branch
                    return self
                }
            } else {
                return self
            }
        }
    }
            } else {
                // unreachable branch
                return self
            }
        }
    }
    
}
