//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.10.2022.
//

import Foundation

internal class PrivoAgeHelpers {
    
    //MARK: - Private properties
    
    private let AGE_FORMAT_YYYYMMDD = "yyyy-MM-dd"
    private let AGE_FORMAT_YYYYMM = "yyyy-MM"
    private let AGE_FORMAT_YYYY = "yyyy"
    
    //MARK: - Internal properties
    
    let serviceSettings: PrivoAgeSettingsInternal
    
    //MARK: - Internal initialisers
    
    init(_ serviceSettings: PrivoAgeSettingsInternal) {
        self.serviceSettings = serviceSettings
    }
    
    //MARK: - Internal functions
    
    func getStatusTargetPage(_ status: AgeGateStatus?, recheckRequired: AgeGateInternalAction?) -> String {
        guard let recheckRequired = recheckRequired else {
            guard let status = status else { return "dob" }
            switch status {
                case .Pending:
                    return "verification-pending"
                case .Blocked:
                    return "access-restricted"
                case .MultiUserBlocked:
                    return "access-restricted"
                case .ConsentRequired:
                    return "request-consent"
                case .AgeVerificationRequired:
                    return "request-age-verification"
                case .IdentityVerificationRequired:
                    return "request-verification"
                case .AgeEstimationBlocked:
                    return "age-detection-description"
                default:
                    return "dob"
            }
        }
        switch(recheckRequired) {
        case .RecheckRequired: return "recheck"
        case .AgeEstimationRequired: return "request-age-estimation"
        case .AgeEstimationRecheckRequired: return "request-age-estimation-recheck"
        }
    }
    
    func toStatus(_ action: AgeGateAction?) -> AgeGateStatus? {
        switch action {
            case .Allow:
                return .Allowed
            case .Block:
                return .Blocked
            case .Consent:
                return .ConsentRequired
            case .IdentityVerify:
                return .IdentityVerificationRequired
            case .AgeVerify:
                return .AgeVerificationRequired
            case .MultiUserBlock:
                return .MultiUserBlocked
            case .AgeEstimationBlocked:
                return .AgeEstimationBlocked
            default:
                return .Undefined
        }
    }
    
    func getDateAndFormat(_ data: CheckAgeData) -> (String,String)? {
        if let birthDateYYYYMMDD = data.birthDateYYYYMMDD {
            return ( birthDateYYYYMMDD, AGE_FORMAT_YYYYMMDD )
        } else if let birthDateYYYYMM = data.birthDateYYYYMM {
            return (birthDateYYYYMM, AGE_FORMAT_YYYYMM)
        } else if let birthDateYYYYMMDD = data.birthDateYYYY {
            return (birthDateYYYYMMDD, AGE_FORMAT_YYYY )
        }
        return nil
    }
    
    func isAgeIntCorrect(_ age: Int) -> Bool {
        age > 0 && age <= 120
    }
    
    func isAgeCorrect(rawDate: String, format: String) -> Bool {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = format
        
        if let date = dateFormatter.date(from:rawDate) {
            let birthYear = calendar.dateComponents([.year], from: date).year
            let currentYear = calendar.dateComponents([.year], from: Date()).year
            if let birthYear = birthYear,
               let currentYear = currentYear {
                let age = currentYear - birthYear
                return isAgeIntCorrect(age)
            }
        }
        return false
    }
    
    func checkNetwork() throws {
        try URLSession.checkNetwork()
    }
    
    func checkUserData(userIdentifier: String?, nickname: String?, agId: String?) async throws {
        if let userIdentifier = userIdentifier, userIdentifier.isEmpty {
            throw AgeGateError.notAllowedEmptyStringUserIdentifier
        }
        if let nickname = nickname {
            if nickname.isEmpty { throw AgeGateError.notAllowedEmptyStringNickname }
            let settings = await serviceSettings.getSettingsT()
            if !settings.isMultiUserOn {
                // we have a Nickname but isMultiUserOn not allowed in partner configuration
                throw AgeGateError.notAllowedMultiUserUsage
            }
        }
        if let agId = agId, agId.isEmpty {
            throw AgeGateError.notAllowedEmptyStringAgId
        }
    }
    
    func checkRequest(_ data: CheckAgeData) async throws {
        try checkNetwork()
        try await checkUserData(userIdentifier: data.userIdentifier, nickname: data.nickname, agId: nil)
        if let (date, format) = getDateAndFormat(data) {
            if !isAgeCorrect(rawDate: date, format: format) {
                throw AgeGateError.incorrectDateOfBirht
            }
        }
        if let age = data.age, !isAgeIntCorrect(age) {
            throw AgeGateError.incorrectAge
        }
    }
    
}
