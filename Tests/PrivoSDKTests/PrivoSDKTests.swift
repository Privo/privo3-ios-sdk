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
        ageGate.getStatus(userIdentifier: UUID().uuidString, nickname: nil) { _ in
            completionExpectation.fulfill()
        } errorHandler: { error in
            XCTFail()
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
    
    func test_age_gate_get_status_undefined__lost_fp() throws {
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        
        // rest results available status, but...
        class TestRestMock: RestMock {
            override func processStatus(data: StatusRecord) async -> AgeGateStatusResponse {
                .mockAvailable
            }
            
            override func processLinkUser(data: LinkUserStatusRecord) async -> AgeGateStatusResponse {
                .mockAvailable
            }
        }
        
        // ... fingerprint will be lost.
        class FpIdServiceMock: FpIdentifiable {
            var fpId: String {
                get throws {
                    throw PrivoError.noInternetConnection
                }
            }
        }

        let rest = TestRestMock()
        let fpIdService = FpIdServiceMock()

        // GIVEN
        let ageGate = PrivoAgeGate(api: rest, fpIdService: fpIdService)
        
        // WHEN
        let completionExpectation = expectation(description: "completion")
        ageGate.getStatus(userIdentifier: "AvailableUS30UserIdentifier", nickname: nil) { ageGateEvent in
            // THEN
            XCTAssert(ageGateEvent.status == .Undefined)
            completionExpectation.fulfill()
        } errorHandler: { error in
            XCTFail()
            completionExpectation.fulfill()
        }
        wait(for: [completionExpectation], timeout: 5.0)
    }
    
    func test_age_gate_run_birthday_nil__lost_fp() throws {
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        
        // rest results available status, but...
        class TestRestMock: RestMock {
            override func processStatus(data: StatusRecord) async -> AgeGateStatusResponse {
                .mockUnavailable
            }
            
            override func processBirthDate(data: FpStatusRecord) async throws -> AgeGateActionResponse {
                return .mockAvailable
            }
        }
        
        // ... fingerprint will be lost.
        class FpIdServiceMock: FpIdentifiable {
            var fpId: String {
                get throws {
                    throw PrivoError.noInternetConnection
                }
            }
        }

        let rest = TestRestMock()
        let fpidService = FpIdServiceMock()

        // GIVEN
        let ageGate = PrivoAgeGate(api: rest, fpIdService: fpidService)
        
        // WHEN
        let completionExpectation = expectation(description: "completion")
        ageGate.run(CheckAgeData(
            userIdentifier: UUID().uuidString,
            birthDateYYYYMMDD: nil,
            birthDateYYYYMM: nil,
            birthDateYYYY: nil,
            age: 30,
            countryCode: "US",
            nickname: nil
        )) { ageGateEvent in
            // THEN
            XCTAssert(ageGateEvent == nil)
            completionExpectation.fulfill()
        }
        wait(for: [completionExpectation], timeout: 5.0)
    }
    
    // MARK: - exception handling in primary public methods
    func test_age_gate_get_status_throws__empty_user_id() throws {
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let rest = RestMock()
        
        // GIVEN
        let ageGate = PrivoAgeGate(api: rest)
        
        // WHEN
        let completionExpectation = expectation(description: "completion").assertForOverFulfill(true)
        ageGate.getStatus(userIdentifier: "") { ageGateEvent in
            XCTFail()
            completionExpectation.fulfill()
        } errorHandler: { error in
            // THEN
            if let ageGateError = error as? AgeGateError {
                XCTAssert(ageGateError == .notAllowedEmptyStringUserIdentifier)
            } else {
                XCTFail()
            }
            completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 5.0)
    }
    
    func test_age_gate_get_status_async_throws__empty_user_id() async throws {
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let rest = RestMock()
        
        // GIVEN
        let ageGate = PrivoAgeGate(api: rest)
        
        // WHEN
        do {
            _ = try await ageGate.getStatus(userIdentifier: "")
        // THEN
        } catch let PrivoError.incorrectInputData(ageGateError as AgeGateError) {
            XCTAssert(ageGateError == .notAllowedEmptyStringUserIdentifier)
        } catch {
            XCTFail("Unexpected type error: \(error)")
        }
    }
    
    func test_age_gate_run_nil__incorrect_age() throws {
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let rest = RestMock()
        
        // GIVEN
        let checkAgeData = CheckAgeData(
            userIdentifier: UUID().uuidString,
            birthDateYYYYMMDD: nil,
            birthDateYYYYMM: nil,
            birthDateYYYY: "1980",
            age: 3000, // .incorrectAge
            countryCode: "US",
            nickname: nil
        )
        let ageGate = PrivoAgeGate(api: rest)
        
        // WHEN
        let completionExpectation = expectation(description: "completion").assertForOverFulfill(true)
        ageGate.run(checkAgeData) { ageGateEvent in
            // THEN
            XCTAssertNil(ageGateEvent)
            completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 5.0)
    }
    
    func test_age_gate_run_async_throws__incorrect_age() async throws {
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let rest = RestMock()
        
        // GIVEN
        let checkAgeData = CheckAgeData(
            userIdentifier: UUID().uuidString,
            birthDateYYYYMMDD: nil,
            birthDateYYYYMM: nil,
            birthDateYYYY: "1980",
            age: 3000, // .incorrectAge
            countryCode: "US",
            nickname: nil
        )
        let ageGate = PrivoAgeGate(api: rest)
        
        // WHEN
        do {
            _ = try await ageGate.run(checkAgeData)
        // THEN
        } catch let PrivoError.incorrectInputData(ageGateError as AgeGateError) {
            XCTAssert(ageGateError == .incorrectAge)
        } catch {
            XCTFail("Unexpected type error: \(error)")
        }
    }
    
    func test_age_gate_recheck_nil__incorrect_birthdate() throws {
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let rest = RestMock()
        
        // GIVEN
        let checkAgeData = CheckAgeData(
            userIdentifier: UUID().uuidString,
            birthDateYYYYMMDD: nil,
            birthDateYYYYMM: nil,
            birthDateYYYY: "one thousand nine hundred eighty", // .incorrectDateOfBirht
            age: 30,
            countryCode: "US",
            nickname: UUID().uuidString
        )
        let ageGate = PrivoAgeGate(api: rest)
        
        // WHEN
        let completionExpectation = expectation(description: "completion").assertForOverFulfill(true)
        ageGate.recheck(checkAgeData) { ageGateEvent in
            // THEN
            XCTAssertNil(ageGateEvent)
            completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 5.0)
    }
    
    func test_age_gate_recheck_async_throws__incorrect_birthdate() async throws {
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let rest = RestMock()
        
        // GIVEN
        let checkAgeData = CheckAgeData(
            userIdentifier: UUID().uuidString,
            birthDateYYYYMMDD: nil,
            birthDateYYYYMM: nil,
            birthDateYYYY: "one thousand nine hundred eighty", // .incorrectDateOfBirht
            age: 30,
            countryCode: "US",
            nickname: UUID().uuidString
        )
        let ageGate = PrivoAgeGate(api: rest)
        
        // WHEN
        do {
            _ = try await ageGate.recheck(checkAgeData)
        // THEN
        } catch let PrivoError.incorrectInputData(ageGateError as AgeGateError) {
            XCTAssert(ageGateError == .incorrectDateOfBirht)
        } catch {
            XCTFail("Unexpected type error: \(error)")
        }
    }
    
    func test_age_gate_link_user_throws__empty_agid() throws {
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let rest = RestMock()
        
        // GIVEN
        let ageGate = PrivoAgeGate(api: rest)
        
        // WHEN
        let completionExpectation = expectation(description: "completion").assertForOverFulfill(true)
        ageGate.linkUser(
            userIdentifier: UUID().uuidString,
            agId: "",
            nickname: nil
        ) { ageGateEvent in
            XCTFail()
            completionExpectation.fulfill()
        } errorHandler: { error in
            // THEN
            if let ageGateError = error as? AgeGateError {
                XCTAssert(ageGateError == .notAllowedEmptyStringAgId)
            } else {
                XCTFail()
            }
            completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 5.0)
    }
    
    func test_age_gate_link_user_async_throws__empty_agid() async throws {
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let rest = RestMock()
        
        // GIVEN
        let ageGate = PrivoAgeGate(api: rest)
        
        // WHEN
        do {
            _ = try await ageGate.linkUser(
                userIdentifier: UUID().uuidString,
                agId: "",
                nickname: nil)
        // THEN
        } catch let PrivoError.incorrectInputData(ageGateError as AgeGateError) {
            XCTAssert(ageGateError == .notAllowedEmptyStringAgId)
        } catch {
            XCTFail("Unexpected type error: \(error)")
        }
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

fileprivate extension AgeGateEvent {
    static let mockAvailable: AgeGateEvent = .init(
        status: .Allowed,
        userIdentifier: "16DF78D2-6B84-44BE-AA66-C5CB5FE876EE",
        nickname: nil,
        agId: "c1c13321-84f1-4cc8-8e04-6b35382080f7",
        ageRange: .init(start: 18, end: 120, jurisdiction: "US"),
        countryCode: "US"
    )
}

fileprivate extension AgeGateActionResponse {
    static let mockAvailable: AgeGateActionResponse = .init(
        action: .Allow,
        agId: "c1c13321-84f1-4cc8-8e04-6b35382080f7",
        ageRange: .init(start: 18, end: 120, jurisdiction: "US"),
        extUserId: nil,
        countryCode: "US"
    )
}
