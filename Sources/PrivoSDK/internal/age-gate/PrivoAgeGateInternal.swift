//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 31.03.2022.
//

import Foundation
import SwiftUI

internal class PrivoAgeGateInternal {
    
    let helpers = PrivoAgeHelpers()
    let storage = AgeGateStorage()
    
    public func processStatus(
        userIdentifier: String?,
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
                    agId: response.agId ?? agId,
                    ageRange: response.ageRange
                )
                completionHandler(event)
            } else {
                completionHandler(AgeGateEvent(
                    status: AgeGateStatus.Undefined,
                    userIdentifier: userIdentifier,
                    agId: agId,
                    ageRange: nil
                ))
            }
        }
    }
    
    internal func getStatusEvent(_ userIdentifier: String?, completionHandler: @escaping (AgeGateEvent) -> Void) {
        let expireEvent = storage.getStoredAgeGateEvent(userIdentifier)
        if (expireEvent?.isExpire == false) {
            if let event = expireEvent?.event {
                // Force return event if we found non-expired one
                completionHandler(event)
                return
            }
        }
        storage.getStoredAgeGateId(userIdentifier) { [weak self] agId in
            self?.storage.getFpId { fpId in
                self?.processStatus(
                    userIdentifier: userIdentifier,
                    agId: agId,
                    fpId: fpId
                ) { event in
                    self?.storage.storeAgeGateEvent(event)
                    completionHandler(event)
                }
            }
        }
    }
    
    private func getCurrentAgeState(
        _ userIdentifier: String?,
        prevEvent: AgeGateEvent?,
        completionHandler: @escaping (AgeState?) -> Void)
    {
        var settings: AgeServiceSettings?
        var event: AgeGateEvent?
        
        storage.getStoredAgeGateId(userIdentifier) { [weak self] agId in
            self?.storage.getFpId() { fpId in
                
                let group = DispatchGroup()

                group.enter()
                group.enter()
                
                self?.storage.serviceSettings.getSettings { s in
                    settings = s
                    group.leave()
                }
                if let prevEvent = prevEvent {
                    event = prevEvent
                    group.leave()
                } else {
                    self?.processStatus(
                        userIdentifier: userIdentifier,
                        agId: agId,
                        fpId: fpId
                    ) { e in
                        event = e
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                       if let settings = settings {
                        completionHandler(AgeState(
                            fpId: fpId,
                            agId: agId,
                            settings: settings,
                            event: event
                        ))
                    } else {
                        completionHandler(nil)
                    }
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
        storage.getStoredAgeGateId(data.userIdentifier) { [weak self] agId in
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
        
        getCurrentAgeState(data.userIdentifier, prevEvent: prevEvent) { state  in
            
            guard let state = state else {
                completionHandler(nil)
                return
            }
            
            let ageGateData = CheckAgeStoreData(
                serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                settings: state.settings,
                userIdentifier: data.userIdentifier,
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
                    targetPage: self.helpers.getStatusTargetPage(state.event?.status, recheckRequired: recheckRequired),
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
    
    internal func hide() {
        UIApplication.shared.dismissTopView()
    }
}
