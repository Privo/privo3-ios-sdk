//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.06.2021.
//

import Foundation

extension URL {

    mutating func appendQueryParam(name: String, value: String?) {

        guard var urlComponents = URLComponents(string: absoluteString) else { return }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // Create query item
        let queryItem = URLQueryItem(name: name, value: value)

        // Append the new query item in the existing query items array
        queryItems.append(queryItem)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        self = urlComponents.url!
    }
    mutating func appendRawPath(_ value: String) {
        let nextString = absoluteString + value
        if let nextURL = URL(string: nextString) {
            self = nextURL
        }
    }
}
