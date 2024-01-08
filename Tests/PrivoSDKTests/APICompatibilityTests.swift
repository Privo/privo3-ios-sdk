import Foundation
import XCTest
import PrivoSDK

// Tests for backward public api compatibility.
// Compiling means the test passed.
// Use all params in methods. Warnings is ok in this file.
final class APICompatibilityTests: XCTestCase {
    
    // MARK: - public api 2.17.0 changed
    
    func test_age_gate_get_status_async_2_17_0() async throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let _: AgeGateEvent = try await Privo.ageGate.getStatus(userIdentifier: UUID().uuidString, nickname: UUID().uuidString)
    }
    
    func test_age_gate_run_async_2_17_0() async throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let checkAgeData = CheckAgeData(
            userIdentifier: UUID().uuidString,
            birthDateYYYYMMDD: nil,
            birthDateYYYYMM: nil,
            birthDateYYYY: "1980",
            age: 30,
            countryCode: "US",
            nickname: UUID().uuidString
        )
        let _: AgeGateEvent = try await Privo.ageGate.run(checkAgeData)
    }
    
    func test_age_gate_recheck_async_2_17_0() async throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let checkAgeData = CheckAgeData(
            userIdentifier: UUID().uuidString,
            birthDateYYYYMMDD: nil,
            birthDateYYYYMM: nil,
            birthDateYYYY: "1980",
            age: 30,
            countryCode: "US",
            nickname: UUID().uuidString
        )
        let _: AgeGateEvent = try await Privo.ageGate.recheck(checkAgeData)
    }
    
    func test_age_gate_link_user_async_2_17_0() async throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let _: AgeGateEvent = try await Privo.ageGate.linkUser(userIdentifier: UUID().uuidString, agId: UUID().uuidString, nickname: UUID().uuidString)
    }
    
    // MARK: - public api changed in 2.15.0
    
    func test_age_gate_get_status_2_15_0() throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        Privo.ageGate.getStatus(
            userIdentifier: UUID().uuidString,
            nickname: UUID().uuidString)
        { (ageGateEvent: AgeGateEvent) in
            // nothing
        } errorHandler: { (error: Error) in
            // nothing
        }
    }
    
    func test_age_gate_run_2_15_0() throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let checkAgeData = CheckAgeData(
            userIdentifier: UUID().uuidString,
            birthDateYYYYMMDD: nil,
            birthDateYYYYMM: nil,
            birthDateYYYY: "1980",
            age: 30,
            countryCode: "US",
            nickname: UUID().uuidString
        )
        Privo.ageGate.run(checkAgeData) { (ageGateEvent: AgeGateEvent?) in
            if ageGateEvent == nil {
                // do nothing
            } else {
                // do nothing
            }
        }
    }
        
    func test_age_gate_recheck_2_15_0() throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let checkAgeData = CheckAgeData(
            userIdentifier: UUID().uuidString,
            birthDateYYYYMMDD: nil,
            birthDateYYYYMM: nil,
            birthDateYYYY: "1980",
            age: 30,
            countryCode: "US",
            nickname: UUID().uuidString
        )
        Privo.ageGate.recheck(checkAgeData) { (ageGateEvent: AgeGateEvent?) in
            if ageGateEvent == nil {
                // do nothing
            } else {
                // do nothing
            }
        }
    }
    
    func test_age_gate_link_user_2_15_0() throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        Privo.ageGate.linkUser(
            userIdentifier: UUID().uuidString,
            agId: UUID().uuidString,
            nickname: UUID().uuidString)
        { (ageGateEvent: AgeGateEvent) in
            // do nothing
        } errorHandler: { (error: Error) in
            // do nothing
        }
    }
        
    // MARK: - public api available in 2.14.0 and early
    
    func test_age_gate_get_status_2_14_0() throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        try Privo.ageGate.getStatus(userIdentifier: UUID().uuidString, nickname: UUID().uuidString) { (ageGateEvent: AgeGateEvent) in
            // nothing
        }
    }
    
    func test_age_gate_run_2_14_0() throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let checkAgeData = CheckAgeData(
            userIdentifier: UUID().uuidString,
            birthDateYYYYMMDD: nil,
            birthDateYYYYMM: nil,
            birthDateYYYY: "1980",
            age: 30,
            countryCode: "US",
            nickname: UUID().uuidString
        )
        try Privo.ageGate.run(checkAgeData) { (ageGateEvent: AgeGateEvent?) in
            if ageGateEvent == nil {
                // do nothing
            } else {
                // do nothing
            }
        }
    }
    
    func test_age_gate_recheck_2_14_0() throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        let checkAgeData = CheckAgeData(
            userIdentifier: UUID().uuidString,
            birthDateYYYYMMDD: nil,
            birthDateYYYYMM: nil,
            birthDateYYYY: "1980",
            age: 30,
            countryCode: "US",
            nickname: UUID().uuidString
        )
        try Privo.ageGate.recheck(checkAgeData) { (ageGateEvent: AgeGateEvent?) in
            if ageGateEvent == nil {
                // do nothing
            } else {
                // do nothing
            }
        }
    }
    
    func test_age_gate_link_user_2_14_0() throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        try Privo.ageGate.linkUser(userIdentifier: UUID().uuidString, agId: UUID().uuidString, nickname: UUID().uuidString, completionHandler: { (ageGateEvent: AgeGateEvent) in
            // do nothing
        })
    }
    
    func test_age_gate_show_identifier_model_2_14_0() throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        try Privo.ageGate.showIdentifierModal(userIdentifier: UUID().uuidString, nickname: UUID().uuidString)
    }
    
    func test_age_gate_hide_2_14_0() throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        Privo.ageGate.hide()
    }
}
