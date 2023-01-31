//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.10.2022.
//

import Foundation

internal class PrivoAgeHelpers {
    
    private let AGE_FORMAT_YYYYMMDD = "yyyy-MM-dd";
    private let AGE_FORMAT_YYYYMM = "yyyy-MM";
    private let AGE_FORMAT_YYYY = "yyyy";
    
    let serviceSettings: PrivoAgeSettingsInternal
    
    init(_ serviceSettings: PrivoAgeSettingsInternal) {
        self.serviceSettings = serviceSettings
    }
    
    internal func getStatusTargetPage(_ status: AgeGateStatus?, recheckRequired: Bool) -> String {
        guard let status = status else {
            return "dob"
        }
        if (recheckRequired == true) {
            return "recheck"
        }
        switch status {
            case AgeGateStatus.Pending:
                return "verification-pending"
            case AgeGateStatus.Blocked:
                return "access-restricted";
            case AgeGateStatus.MultiUserBlocked:
                return "access-restricted";
            case AgeGateStatus.ConsentRequired:
                return "request-consent";
            case AgeGateStatus.AgeVerificationRequired:
                return "request-age-verification";
            case AgeGateStatus.IdentityVerificationRequired:
                return "request-verification";
            default:
                return "dob";
        }
    };
    
    internal func toStatus(_ action: AgeGateAction?) -> AgeGateStatus? {
        switch action {
            case .Allow:
                return AgeGateStatus.Allowed
            case .Block:
                return AgeGateStatus.Blocked
            case .Consent:
                return AgeGateStatus.ConsentRequired
            case .IdentityVerify:
                return AgeGateStatus.IdentityVerificationRequired
            case .AgeVerify:
                return AgeGateStatus.AgeVerificationRequired
            case .MultiUserBlock:
                return AgeGateStatus.MultiUserBlocked
            default:
                return AgeGateStatus.Undefined
        }
    }
    
    internal func getDateAndFormat(_ data: CheckAgeData) -> (String,String)? {
        if let birthDateYYYYMMDD = data.birthDateYYYYMMDD {
            return ( birthDateYYYYMMDD, AGE_FORMAT_YYYYMMDD );
        } else if let birthDateYYYYMM = data.birthDateYYYYMM {
            return (birthDateYYYYMM, AGE_FORMAT_YYYYMM);
        } else if let birthDateYYYYMMDD = data.birthDateYYYY {
            return (birthDateYYYYMMDD, AGE_FORMAT_YYYY );
        }
        return nil
    }
    
    internal func isAgeCorrect(rawDate: String, format: String) -> Bool {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = format
        
        if let date = dateFormatter.date(from:rawDate) {
            let birthYear = calendar.dateComponents([.year], from: date).year
            let currentYear = calendar.dateComponents([.year], from: Date()).year
            if let birthYear = birthYear,
               let currentYear = currentYear {
                let age = currentYear - birthYear;
                return age > 0 && age <= 120;
            }
        }
        return false
    }
    
    internal func checkNetwork() throws {
        try PrivoInternal.rest.checkNetwork()
    }
    
    internal func checkUserData(userIdentifier: String?, nickname: String?, agId: String? = nil) throws {
        if let userIdentifier = userIdentifier {
            if (userIdentifier.isEmpty) {
                throw AgeGateError.notAllowedEmptyStringUserIdentifier
            }
        }
        if let nickname = nickname {
            
            if (nickname.isEmpty) {
                throw AgeGateError.notAllowedEmptyStringNickname
            }
            serviceSettings.getSettingsT { settings in
                if (!settings.isMultiUserOn) {
                    // we have a Nickname but isMultiUserOn not allowed in partner configuration
                    throw AgeGateError.notAllowedMultiUserUsage
                }
            }
        }
        if let agId = agId {
            if (agId.isEmpty) {
                throw AgeGateError.notAllowedEmptyStringAgId
            }
        }
    }
    
    internal func checkRequest(_ data: CheckAgeData) throws {

        try checkNetwork()
        try checkUserData(userIdentifier: data.userNickname, nickname: data.userNickname)
        if let (date, format) = getDateAndFormat(data) {
            if (isAgeCorrect(rawDate: date, format: format) == false) {
                throw AgeGateError.incorrectDateOfBirht
            }
        }
    }
}

