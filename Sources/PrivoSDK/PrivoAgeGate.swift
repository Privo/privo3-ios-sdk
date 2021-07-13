//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 06.07.2021.
//
import Foundation
import UIKit

public class PrivoAgeGate {
    private let AG_ID = "agId";
    // private let FP_ID = "fpId";
    private let dateFormatter = DateFormatter()

    public init() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    public func getAgeStatus(extUserId: String? = nil, countryCode: String? = nil, completionHandler: @escaping (AgeGateStatus?) -> Void) {
        if let agId = UserDefaults.standard.string(forKey: AG_ID) {
            let record = AgStatusRecord(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, agId: agId, extUserId: extUserId, countryCode: countryCode)
            PrivoInternal.rest.processAgStatus(data: record) { r in
                if let id = r?.ageGateIdentifier {
                    UserDefaults.standard.set(id, forKey: self.AG_ID)
                    completionHandler(r)
                } else {
                    UserDefaults.standard.removeObject(forKey: self.AG_ID)
                    completionHandler(nil)
                }
            }
        } else {
            completionHandler(nil)
        }
    }
    public func getAgeStatusByBirthDate(birthDate: Date? = nil, extUserId: String? = nil, countryCode: String? = nil, completionHandler: @escaping (AgeGateStatus?) -> Void) {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        let textDate = dateFormatter.string(from: birthDate)
        let record = BirthDateStatusRecord(serviceIdentifier: PrivoInternal.settings.serviceIdentifier,deviceId: deviceId, birthDate: textDate, extUserId: extUserId, countryCode: countryCode)
        PrivoInternal.rest.processDirthDate(data: record) { r in
            UserDefaults.standard.set(data.agId, forKey: self.AG_ID)
            completionHandler(r)
        }
    }
}
