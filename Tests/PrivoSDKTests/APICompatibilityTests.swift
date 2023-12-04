//
//  File.swift
//  
//
//  Created by Andrey Yo on 28.11.2023.
//


import Foundation
import XCTest
import PrivoSDK


// Tests for backward public api compatibility.
// Compiling means the test passed.
// Use all params in methods. Warnings is ok in this file.
final class APICompatibilityTests: XCTestCase {
    
    func test_age_gate_get_status() throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        try Privo.ageGate.getStatus(userIdentifier: UUID().uuidString, nickname: UUID().uuidString) { (ageGateEvent: AgeGateEvent) in
            // nothing
        }
    }
    
    func test_age_gate_run() throws {
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
    
    func test_age_gate_recheck() throws {
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
    
    func test_age_gate_link_user() throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        try Privo.ageGate.linkUser(userIdentifier: UUID().uuidString, agId: UUID().uuidString, nickname: UUID().uuidString, completionHandler: { (ageGateEvent: AgeGateEvent) in
            // do nothing
        })
    }
    
    func test_age_gate_show_identifier_model() throws {
        throw XCTSkip("Compiling means the test passed. Skip to avoid network requests.")
        Privo.initialize(settings: PrivoSettings(serviceIdentifier: "privolock", envType: .Dev))
        try Privo.ageGate.showIdentifierModal(userIdentifier: UUID().uuidString, nickname: UUID().uuidString)
    }
}
