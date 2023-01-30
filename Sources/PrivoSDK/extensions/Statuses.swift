//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 13.04.2022.
//

import Foundation

extension AgeGateStatusTO {
    func toStatus() -> AgeGateStatus {
        
        switch self {
            case .Pending:
                return AgeGateStatus.Pending
            case .Allowed:
                return AgeGateStatus.Allowed
            case .Blocked:
                return AgeGateStatus.Blocked
            case .ConsentRequired:
                return AgeGateStatus.ConsentRequired
            case .ConsentApproved:
                return AgeGateStatus.ConsentApproved
            case .ConsentDenied:
                return AgeGateStatus.ConsentDenied
            case .IdentityVerificationRequired:
                return AgeGateStatus.IdentityVerificationRequired
            case .IdentityVerified:
                return AgeGateStatus.IdentityVerified
            case .AgeVerificationRequired:
                return AgeGateStatus.AgeVerificationRequired
            case .AgeVerified:
                return AgeGateStatus.AgeVerified
            case .AgeBlocked:
                return AgeGateStatus.AgeBlocked
            case .MultiUserBlocked:
                return AgeGateStatus.MultiUserBlocked
            default:
                return AgeGateStatus.Undefined;
        }
    }
}
