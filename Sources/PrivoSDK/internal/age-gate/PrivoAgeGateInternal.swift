//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 31.03.2022.
//

import Foundation
import SwiftUI

internal class PrivoAgeGateInternal {
    
    let storage: AgeGateStorage
    let helpers: PrivoAgeHelpers
    
    init() {
        self.storage = AgeGateStorage()
        self.helpers = PrivoAgeHelpers(self.storage.serviceSettings)
    }
    
    public func processStatus(
        userIdentifier: String?,
        nickname: String?,
        agId: String?,
        fpId: String,
        completionHandler: @escaping (AgeGateEvent) -> Void) {
        let record = StatusRecord(
            serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
            fpId: fpId,
            agId: agId,
            extUserId: userIdentifier
        )
        PrivoInternal.rest.processStatus(data: record) { response in
            if let response = response {
                let event = AgeGateEvent(
                    status: response.status.toStatus(),
                    userIdentifier: userIdentifier,
                    nickname: nickname,
                    agId: response.agId ?? agId,
                    ageRange: response.ageRange
                )
                completionHandler(event)
            } else {
                completionHandler(AgeGateEvent(
                    status: AgeGateStatus.Undefined,
                    userIdentifier: userIdentifier,
                    nickname: nickname,
                    agId: agId,
                    ageRange: nil
                ))
            }
        }
    }
    
    internal func getStatusEvent(_ userIdentifier: String?, nickname: String?, completionHandler: @escaping (AgeGateEvent) -> Void) {
        storage.getStoredAgeGateId(userIdentifier: userIdentifier, nickname: nickname) { [weak self] agId in
            self?.storage.getFpId { fpId in
                if (agId == nil && nickname != nil) {
                    // for case of a new nickname
                    self?.processStatus(
                        userIdentifier: nil,
                        nickname: nickname,
                        agId: nil,
                        fpId: fpId,
                        completionHandler: completionHandler
                    )
                } else {
                    self?.processStatus(
                        userIdentifier: userIdentifier,
                        nickname: nickname,
                        agId: agId,
                        fpId: fpId,
                        completionHandler: completionHandler
                    )
                }
            }
        }
    }
    
    public func linkUser(
        userIdentifier: String,
        agId: String,
        nickname: String?,
        completionHandler: @escaping (AgeGateEvent) -> Void) {
            
            storage.getAgeGateStoredEntities() { entities in
                let isKnownAgId = entities.contains { $0.agId == agId}
                if (isKnownAgId == false) {
                    // send flag to metrics and continue (not stop)
                    let warning = AgeGateLinkWarning(descripteion: "Age Gate Id wasn't found in the store during Age Gate 'link user' call", agIdEntities: entities)
                    if let data = try? JSONEncoder().encode(warning) {
                        let stringData = String(decoding: data, as: UTF8.self)
                        let event = AnalyticEvent(serviceIdentifier: PrivoInternal.settings.serviceIdentifier, data: stringData)
                        PrivoInternal.rest.sendAnalyticEvent(event)
                    }
                }
                
                let record = LinkUserStatusRecord(
                    serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                    agId: agId,
                    extUserId: userIdentifier
                )
                PrivoInternal.rest.processLinkUser(data: record) { response in
                    if let response = response {
                        let event = AgeGateEvent(
                            status: response.status.toStatus(),
                            userIdentifier: userIdentifier,
                            nickname: nickname,
                            agId: response.agId ?? agId,
                            ageRange: response.ageRange
                        )
                        completionHandler(event)
                    } else {
                        completionHandler(AgeGateEvent(
                            status: AgeGateStatus.Undefined,
                            userIdentifier: userIdentifier,
                            nickname: nickname,
                            agId: agId,
                            ageRange: nil
                        ))
                    }
                }
            }
    }
    
    internal func getAgeGateState(userIdentifier: String?,
                                  niсkname: String?,
                                  completionHandler: @escaping (AgeState?) -> Void
    ) {
        storage.getStoredAgeGateId(userIdentifier: userIdentifier, nickname: niсkname) { [weak self] agId in
            self?.storage.getFpId() { fpId in
                self?.storage.serviceSettings.getSettings { settings in
                    completionHandler(AgeState(
                        fpId: fpId,
                        agId: agId,
                        settings: settings
                    ))
                }
            }
        }
    }
    
    
    internal func runAgeGateByBirthDay(_ data: CheckAgeData, completionHandler: @escaping (AgeGateEvent?) -> Void) {
        storage.getFpId() { fpId in
            // make a rest call
            let record = FpStatusRecord(
                serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                fpId: fpId,
                birthDate: data.birthDateYYYYMMDD,
                birthDateYYYYMM: data.birthDateYYYYMM,
                birthDateYYYY: data.birthDateYYYY,
                extUserId: data.userIdentifier,
                countryCode: data.countryCode
            )
            PrivoInternal.rest.processBirthDate(data: record) { [weak self] r in
                if let response = r,
                   let status = self?.helpers.toStatus(response.action) {
                    let event = AgeGateEvent(
                        status: status,
                        userIdentifier: data.userIdentifier,
                        nickname: data.userNickname,
                        agId: response.agId,
                        ageRange: response.ageRange
                    )
                    if (response.action == AgeGateAction.Consent || response.action == AgeGateAction.IdentityVerify || response.action == AgeGateAction.AgeVerify) {
                        self?.runAgeGate(
                            data,
                            prevEvent: event,
                            recheckRequired: false,
                            completionHandler: completionHandler
                        )
                    } else {
                        completionHandler(event)
                    }
                } else {
                    completionHandler(nil)
                }
            }
        }
    }
    internal func recheckAgeGateByBirthDay(
        _ data: CheckAgeData,
        completionHandler: @escaping (AgeGateEvent?) -> Void
    ) {
        storage.getStoredAgeGateId(userIdentifier: data.userIdentifier, nickname: data.userNickname) { [weak self] agId in
            if let agId = agId {
                // make a rest call
                let record = RecheckStatusRecord(
                    serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                    agId: agId,
                    birthDate: data.birthDateYYYYMMDD,
                    birthDateYYYYMM: data.birthDateYYYYMM,
                    birthDateYYYY: data.birthDateYYYY,
                    countryCode: data.countryCode
                )
                PrivoInternal.rest.processRecheck(data: record) { r in
                    if let response = r,
                       let status = self?.helpers.toStatus(response.action) {
                        let event = AgeGateEvent(
                            status: status,
                            userIdentifier: data.userIdentifier,
                            nickname: data.userNickname,
                            agId: response.agId,
                            ageRange: response.ageRange
                        )
                        if (response.action == AgeGateAction.Consent || response.action == AgeGateAction.IdentityVerify || response.action == AgeGateAction.AgeVerify) {
                            self?.runAgeGate(
                                data,
                                prevEvent: event,
                                recheckRequired: false,
                                completionHandler: completionHandler
                            )
                        } else {
                            completionHandler(event)
                        }
                    } else {
                        completionHandler(nil)
                    }
                }
            }
        }
    }
    
    internal func runAgeGate(
        _ data: CheckAgeData,
        prevEvent: AgeGateEvent?,
        recheckRequired: Bool,
        completionHandler: @escaping (AgeGateEvent?) -> Void
    ) {
        
        getAgeGateState(userIdentifier: data.userIdentifier, niсkname: data.userNickname) { state  in
            
            guard let state = state else {
                completionHandler(nil)
                return
            }
            
            let ageGateData = CheckAgeStoreData(
                serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                settings: state.settings,
                userIdentifier: data.userIdentifier,
                nickname: data.userNickname,
                countryCode: data.countryCode,
                birthDateYYYYMMDD: data.birthDateYYYYMMDD,
                birthDateYYYYMM: data.birthDateYYYYMM,
                birthDateYYYY: data.birthDateYYYY,
                redirectUrl: PrivoInternal.configuration.ageGatePublicUrl.withPath("/index.html#/age-gate-loading")!.absoluteString,
                agId: state.agId,
                fpId: state.fpId
            )
            UIApplication.shared.showView(false) {
                AgeGateView(
                    ageGateData : ageGateData,
                    targetPage: self.helpers.getStatusTargetPage(prevEvent?.status, recheckRequired: recheckRequired),
                    onFinish: { events in
                        events.forEach { event in
                            completionHandler(event)
                        }
                        if (events.isEmpty) {
                            completionHandler(nil)
                        }
                        UIApplication.shared.dismissTopView()
                    })
            }
        }
    }
    internal func showAgeGateIdentifier(userIdentifier: String?, nickname: String?) {
        storage.getStoredAgeGateId(userIdentifier: userIdentifier, nickname: nickname) { [weak self] agId in
            self?.storage.getFpId() { fpId in
                self?.storage.serviceSettings.getSettings { settings in
                    let ageGateData = CheckAgeStoreData(
                        serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                        settings: settings,
                        userIdentifier: userIdentifier,
                        nickname: nickname,
                        countryCode: nil,
                        birthDateYYYYMMDD: nil,
                        birthDateYYYYMM: nil,
                        birthDateYYYY: nil,
                        redirectUrl: nil,
                        agId: agId,
                        fpId: fpId
                    )
                    UIApplication.shared.showView(false) {
                        AgeGateView(
                            ageGateData : ageGateData,
                            targetPage: "age-gate-identifier",
                            finishCriteria: "identifier-closed",
                            onFinish:  { _ in
                                UIApplication.shared.dismissTopView()
                            }
                        )
                    }
                }
            }
        }
    }
    
    internal func hide() {
        UIApplication.shared.dismissTopView()
    }
}
