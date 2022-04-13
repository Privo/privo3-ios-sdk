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
            case AgeGateStatusTO.Blocked:
                return AgeGateStatus.Blocked;
            case AgeGateStatusTO.Allowed:
                return AgeGateStatus.Allowed;
            case AgeGateStatusTO.ConsentApproved:
                return AgeGateStatus.ConsentApproved;
            case AgeGateStatusTO.ConsentDeclined:
                return AgeGateStatus.ConsentDeclined;
            case AgeGateStatusTO.Pending:
                return AgeGateStatus.Pending;
            default:
                return AgeGateStatus.Undefined;
        }
    }
}
