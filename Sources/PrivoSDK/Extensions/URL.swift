import Foundation

extension URL {

    func withQueryParam(name: String, value: String?) -> URL? {
        guard var urlComponents = URLComponents(string: absoluteString) else { return nil }
        var queryItems = urlComponents.queryItems ?? []
        let queryItem = URLQueryItem(name: name, value: value)
        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
    
    func withPath(_ value: String) -> URL? {
        let nextString = absoluteString + value
        return URL(string: nextString)
    }
    
}
