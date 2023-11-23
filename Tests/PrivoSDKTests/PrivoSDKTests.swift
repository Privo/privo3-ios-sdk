import XCTest
@testable import PrivoSDK


final class PrivoSDKTests: XCTestCase {
    
    // MARK: - analytics event logs
    
    func test_analytics_event() throws {
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))

        // mock requests
        let statusURL = PrivoInternal.configuration.ageGateBaseUrl.appending(.status)
        let analyticURL = PrivoInternal.configuration.commonUrl.appending(.analytic)
        let fingerprintURL = PrivoInternal.configuration.authBaseUrl.appending(.api).appending(.v1_0).appending(.fingerprint)
        let settingsURL = PrivoInternal.configuration.ageGateBaseUrl.appending(.settings)
        URLMock.urls = [
            statusURL: (error: nil,
                        data: "The requested resource could not be found.".data(using: .utf8),
                        response: HTTPURLResponse(url: statusURL, statusCode: 404, headerFields: ["Content-Length": "42"])),
            analyticURL: (error: nil,
                          data: nil,
                          response: HTTPURLResponse(url: analyticURL, statusCode: 200, headerFields: ["Content-Length": "0"])),
            fingerprintURL: (error: nil,
                             data: try JSONEncoder().encode(DeviceFingerprintResponse.mockSuccess),
                             response: HTTPURLResponse(url: fingerprintURL, statusCode: 200)),
            settingsURL: (error: nil,
                          data: try JSONEncoder().encode(AgeServiceSettings.mockSuccess),
                          response: HTTPURLResponse(url: settingsURL, statusCode: 200))
        ]
        let urlConfig: URLSessionConfiguration = .default
        urlConfig.protocolClasses = [ URLMock.self ]
        let rest = Rest(urlConfig: urlConfig)
        
        // GIVEN
        let ageGate = PrivoAgeGate(api: rest)
        
        // WHEN
        let completionExpectation = expectation(description: "completion")
        try ageGate.getStatus(userIdentifier: UUID().uuidString, nickname: nil) { _ in
            completionExpectation.fulfill()
        }
        wait(for: [completionExpectation], timeout: 5.0)
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for 0.5 seconds all requests.")], timeout: 0.5)
        
        // THEN
        // will send one analytic request for bad response:
        let allAnalyticRequests = URLMock.invokedRequests.filter({ $0.url?.hasSuffix(.analytic) ?? false })
        XCTAssertTrue( allAnalyticRequests.count == 1 )
        if let analyticEventErrorData = allAnalyticRequests.first?.analyticEventErrorData {
            XCTAssertEqual(analyticEventErrorData.errorCode, 404)
        } else {
            XCTFail("Request contains incorrect data.")
        }

    }
}
        
    }
    
    
        
        }
        
        }
    }
    
}




fileprivate extension HTTPURLResponse {
    convenience init?(url: URL, statusCode: Int, headerFields: [String: String] = [:]) {
        self.init(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headerFields)
    }
}
