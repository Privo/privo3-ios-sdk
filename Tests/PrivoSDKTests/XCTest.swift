//
//  File.swift
//  
//
//  Created by Andrey Yo on 28.11.2023.
//


import Foundation
import XCTest

extension XCTestExpectation {
    
    func assertForOverFulfill(_ isOverFulfill: Bool) -> Self {
        self.assertForOverFulfill = isOverFulfill
        return self
    }
}
