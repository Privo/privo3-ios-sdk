import XCTest
@testable import PrivoSDK


final class PrivoSDKTests: XCTestCase {
    
    // MARK: - analytics event logs
    
    func test_analytics_event() async {
        // GIVEN
        // configured one bad response:
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        
        let statusURL = PrivoInternal.configuration.ageGateBaseUrl.status
        let headers = [
            "Content-Length": "42",
        ]
        
        let response = HTTPURLResponse(url: statusURL, statusCode: 404, httpVersion: nil, headerFields: headers)
        
        URLMock.urls = [statusURL: (error: nil,
                                      data: "The requested resource could not be found.".data(using: .utf8),
                                      response: response)]
        
        let urlConfig: URLSessionConfiguration = .default
        urlConfig.protocolClasses = [ URLMock.self ]
        
        let ageGate = PrivoAgeGate(urlConfig: urlConfig)
        
        // WHEN
        _ = try! await ageGate.getStatus(userIdentifier: UUID().uuidString, nickname: nil)
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for 0.5 seconds all requests.")], timeout: 0.5)
        
        // THEN
        // will send one analytic request for bad response:
        let allAnalyticRequests = URLMock.invokedRequests.filter({ $0.url?.isAnalytic ?? false })
        XCTAssertTrue( allAnalyticRequests.count == 1 )
        if let analyticEventErrorData = allAnalyticRequests.first?.analyticEventErrorData {
            XCTAssertEqual(analyticEventErrorData.errorCode, 404)
        } else {
            XCTFail("Request contains incorrect data.")
        }

    }
}


class URLMock: URLProtocol {
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
    private static let queue = DispatchQueue(label: "\(type(of: URLMock.self))")

    override class func canInit(with request: URLRequest) -> Bool {
        queue.async {
            Self._invokedRequests.append(request)
        }
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


extension PrivoAgeGate {
    func getStatus(userIdentifier: String?, nickname: String? = nil) async throws -> AgeGateEvent {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try self.getStatus(userIdentifier: userIdentifier, nickname: nickname) { ageGateEvent in
                    continuation.resume(returning: ageGateEvent)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
