//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 06.04.2022.
//

import Foundation

extension AgeGateEventInternal {
    
    private func toStatus() -> AgeGateStatus? {
        if (status == AgeGateStatusInternal.Closed) {
            // Skip internal statuses
            return nil
        } else {
            return AgeGateStatus.init(rawValue: status.rawValue)
        }
        
    }
    
    func toEvent(nickname: String?) -> AgeGateEvent? {
        if let status = toStatus() {
            return AgeGateEvent(status: status, userIdentifier: userIdentifier, nickname: nickname, agId: agId, ageRange: ageRange)
        }
        return nil
    }
}


extension AgeVerificationEventInternal {
    
    private func toStatus() -> AgeVerificationStatus? {
        if (status == AgeVerificationStatusInternal.Closed) {
            // Skip internal statuses
            return nil
        } else {
            return AgeVerificationStatus.init(rawValue: status.rawValue)
        }
        
    }
    
    func toEvent() -> AgeVerificationEvent? {
        if let status = toStatus() {
            return AgeVerificationEvent(
                status: status,
                profile: profile
            )
        }
        return nil
    }
}
