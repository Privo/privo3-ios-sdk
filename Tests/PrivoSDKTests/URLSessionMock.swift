//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

class URLSessionMock: URLProtocol {
    typealias URLResult = (error: Error?, data: Data?, response: HTTPURLResponse?)
   
    // MARK: class methods
    static var invokedRequests: [URLRequest] {
        get {
            return queue.sync(execute: { Self._invokedRequests })
        }
        set {
            queue.async {
                Self._invokedRequests = newValue
            }
        }
    }
    
    static var urls: [URL: URLResult] {
        get {
            return queue.sync(execute: { Self._urls })
        }
        set {
            queue.async {
                Self._urls = newValue
            }
        }
    }
    private static var _invokedRequests: [URLRequest] = []
    private static var _urls: [URL: URLResult] = [:]
    private static let queue = DispatchQueue(label: "\(type(of: URLSessionMock.self))")

    override class func canInit(with request: URLRequest) -> Bool {
        queue.async {
            Self._invokedRequests.append(request)
        }
        
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Required to be implemented here. Just return what is passed
        return request
    }
    
    // MARK: instance methods
    
    override func startLoading() {
        guard let requestURL = request.url,
              let (error, data, response) = Self.urls[requestURL]
        else {
            // unreachable branch
            let unreachableBranchError = NSError(domain: NSURLErrorDomain, code:NSURLErrorUnknown, userInfo: nil)
            client?.urlProtocol(self, didFailWithError: unreachableBranchError)
            return
        }

        if let response = response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let data = data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {
        // Required to be implemented. Do nothing here.
    }
}
