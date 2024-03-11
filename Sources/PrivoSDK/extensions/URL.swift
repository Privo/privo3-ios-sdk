import Foundation

extension URL {
    func withQueryParam(replace: Bool = false,
                        name: String, value: String?) -> URL {
        let queryItem = URLQueryItem(name: name, value: value)
        if replace {
            return self.reassigningQueryItems([queryItem])
        } else {
            return self.appendingQueryItems([queryItem])
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
    
    func reassigningQueryItems(_ queryItems: [URLQueryItem]) -> URL {
        var queryItemsHashMap: [String: String] = [:]
        queryItems.forEach {
            queryItemsHashMap[$0.name.lowercased()] = $0.value
        }
        
        if var urlComponents = URLComponents(string: self.absoluteString) {
            let queryItemsOld = urlComponents.queryItems ?? []
            let queryItemsFiltered = queryItemsOld.filter {
                queryItemsHashMap[$0.name.lowercased()] == nil
            }
            let queryItemsUpdated = queryItemsFiltered + queryItems
            urlComponents.queryItems = queryItemsUpdated
            
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
