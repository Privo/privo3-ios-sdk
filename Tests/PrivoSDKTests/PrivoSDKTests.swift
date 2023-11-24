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
        URLSessionMock.urls = [
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
        urlConfig.protocolClasses = [ URLSessionMock.self ]
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
        let allAnalyticRequests = URLSessionMock.invokedRequests.filter({ $0.url?.hasSuffix(.analytic) ?? false })
        XCTAssertTrue( allAnalyticRequests.count == 1 )
        if let analyticEventErrorData = allAnalyticRequests.first?.analyticEventErrorData {
            XCTAssertEqual(analyticEventErrorData.errorCode, 404)
        } else {
            XCTFail("Request contains incorrect data.")
        }
        
    }
    
    // MARK: - lost fp cases
    
    func test_lost_fp_get_status() throws {
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        
        // rest results available status, but...
        class TestRestMock: RestMock {
            override func processStatus(data: StatusRecord) async -> AgeGateStatusResponse? {
                .mockAvailable
            }
            
            override func processLinkUser(data: LinkUserStatusRecord) async -> AgeGateStatusResponse? {
                .mockAvailable
            }
        }
        
        // ... fingerprint will be lost.
        class FpIdServiceMock: IFpIdService {
            var fpId: String? { return nil }
        }

        let rest = TestRestMock()
        let fpIdService = FpIdServiceMock()

        // GIVEN
        let ageGate = PrivoAgeGate(api: rest, fpIdService: fpIdService)
        
        // WHEN
        let completionExpectation = expectation(description: "completion")
        try ageGate.getStatus(userIdentifier: "AvailableUS30UserIdentifier", nickname: nil) { ageGateEvent in
            // THEN
            XCTAssert(ageGateEvent.status == .Undefined)
            completionExpectation.fulfill()
        }
        wait(for: [completionExpectation], timeout: 5.0)
    }
    
}




fileprivate extension HTTPURLResponse {
    convenience init?(url: URL, statusCode: Int, headerFields: [String: String] = [:]) {
        self.init(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headerFields)
    }
}

fileprivate extension AgeGateStatusResponse {
    static let mockAvailable: AgeGateStatusResponse = .init(
        status: .Allowed,
        agId: "1cf38293-c1ab-47b1-ab30-95ad447fa5dd",
        ageRange: .init(start: 18, end: 120, jurisdiction: "US"),
        extUserId: nil,
        countryCode: "US"
    )
}
