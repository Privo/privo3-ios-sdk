    import XCTest
    @testable import PrivoSDK

    final class PrivoSDKTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
            XCTAssertEqual(PrivoInternal.configuration.type, .Dev)
        }

class URLMock: URLProtocol {
    typealias URLResult = (error: Error?, data: Data?, response: HTTPURLResponse?)
   
    // MARK: class methods
    
    // TODO: concurrencty
    static var urls: [URL: URLResult] = [:]
    static var invokedRequests: [URLRequest] = []
    
    override class func canInit(with request: URLRequest) -> Bool {
        invokedRequests.append(request)
                
        if let requestURL: URL = request.url {
            return Self.urls[requestURL] != nil
        } else {
            return false
        }
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

        if let response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {
        // Required to be implemented. Do nothing here.
    }
}
