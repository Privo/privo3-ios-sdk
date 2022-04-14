//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 06.04.2022.
//

import Foundation

extension AgeGateEventInternal {
    
    private func toStatus() -> AgeGateStatus? {
        if (status == AgeGateStatusInternal.OpenVerification || status == AgeGateStatusInternal.CloseAgeGate) {
            // Skip internal statuses
            return nil
        } else {
            return AgeGateStatus.init(rawValue: status.rawValue)
        }
        
    }
    
    func toEvent() -> AgeGateEvent? {
        if let status = toStatus() {
            return AgeGateEvent(status: status, userIdentifier: userIdentifier, agId: agId)
        }
        return nil
    }
}

