//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.06.2021.
//

import Foundation

extension URL {

    func withQueryParam(name: String, value: String?) -> URL? {
        if var urlComponents = URLComponents(string: self.absoluteString) {
            // Create array of existing query items
            var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

            // Create query item
            let queryItem = URLQueryItem(name: name, value: value)

            // Append the new query item in the existing query items array
            queryItems.append(queryItem)

            // Append updated query items array in the url component object
            urlComponents.queryItems = queryItems

            // Returns the url from new url components
            return urlComponents.url
        } else {
            return nil
        }

    }
    func withPath(_ value: String) -> URL?  {
        let nextString = absoluteString + value
        return URL(string: nextString)
    }
}
