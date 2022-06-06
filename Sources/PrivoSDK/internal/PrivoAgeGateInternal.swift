//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 31.03.2022.
//

import Foundation
import SwiftUI

internal class PrivoAgeGateInternal {
    private let FP_ID_KEY = "privoFpId";
    private let AGE_EVENT_KEY_PREFIX = "AgeGateEvent"
    private let keychain = PrivoKeychain()
    private let serviceSettings = PrivoAgeSettingsInternal()
    
    internal func storeAgeGateEvent(_ event: AgeGateEvent?) {
        
        func getEventExpiration (_ interval: Double) -> TimeInterval {
            if (event?.status == AgeGateStatus.Pending) {
                // Pending Events are always expired and should be re-fetched
                return Date().timeIntervalSince1970
            } else {
                return (Date() + interval).timeIntervalSince1970
            }
        };
        
        if let event = event {
            if (event.status != AgeGateStatus.Canceled && event.status != AgeGateStatus.Undefined) {
                serviceSettings.getSettings { [weak self] settings in
                    let interval = Double(settings.poolAgeGateStatusInterval)
                    let expireEvent = AgeGateExpireEvent(event: event, expires: getEventExpiration(interval))
                    if let jsonData = try? JSONEncoder().encode(expireEvent),
                       let self = self {
                        let jsonString = String(decoding: jsonData, as: UTF8.self)
                        let key = "\(self.AGE_EVENT_KEY_PREFIX)-\(event.userIdentifier ?? "")"
                        self.keychain.set(key: key, value: jsonString)
                    }
                }
            }
        }
    }
    
    internal func getAgeGateEvent(_ userIdentifier: String?, completionHandler: @escaping (AgeGateIsExpireEvent?) -> Void) {
        let key = "\(AGE_EVENT_KEY_PREFIX)-\(userIdentifier ?? "")"
        if let jsonString = keychain.get(key),
           let jsonData = jsonString.data(using: .utf8),
           let value = try? JSONDecoder().decode(AgeGateExpireEvent.self, from: jsonData) {
            let event = AgeGateIsExpireEvent(event: value.event, isExpire: value.expires < Date().timeIntervalSince1970)
            completionHandler(event)
         } else {
             completionHandler(nil)
         }
    }
    
    internal func getStatusEvent(_ userIdentifier: String?, completionHandler: @escaping (AgeGateEvent) -> Void) {
        getAgeGateEvent(userIdentifier) { [weak self] expireEvent in
            if (expireEvent?.isExpire == false) {
                if let event = expireEvent?.event {
                    // Force return event if we found non-expired one
                    completionHandler(event)
                    return
                }
            }
            let event = expireEvent?.event
            self?.getFpId { fpId in
                let agId = expireEvent?.event.agId
                if let agId = agId,
                   let fpId = fpId {
                    let record = StatusRecord(
                        serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                        fpId: fpId,
                        agId: agId,
                        extUserId: userIdentifier
                    )
                    PrivoInternal.rest.processStatus(data: record) { response in
                        if let response = response {
                            let event = AgeGateEvent(status: response.toStatus(), userIdentifier: userIdentifier, agId: agId)
                            completionHandler(event)
                        } else {
                            completionHandler(AgeGateEvent(
                                status: AgeGateStatus.Undefined,
                                userIdentifier: userIdentifier,
                                agId: agId
                            ))
                        }
                    }
                } else {
                    completionHandler(AgeGateEvent(
                        status: event?.status ?? AgeGateStatus.Undefined,
                        userIdentifier: userIdentifier,
                        agId: event?.agId
                    ))
                }
            }
        }
    }
    
    func getStatusTargetPage(_ status: AgeGateStatus?, recheckRequired: Bool) -> String {
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
    
    private func prepareSettings(_ userIdentifier: String?, completionHandler: @escaping (AgeServiceSettings?,String?) -> Void) {
        var settings: AgeServiceSettings?
        var fpId: String? = nil
        
        let group = DispatchGroup()

        group.enter()
        group.enter()
        
        serviceSettings.getSettings { s in
            settings = s
            group.leave()
        }

        getFpId() { r in
            fpId = r
            group.leave()
        }
        group.notify(queue: .main) {
            completionHandler(settings,fpId)
        }
        
        return ()
        
    }
    
    internal func runAgeGateByBirthDay(_ data: CheckAgeData, completionHandler: @escaping (AgeGateEvent?) -> Void) {
        self.getFpId() { fpId in
            if let birthDateYYYMMDD = data.birthDateYYYYMMDD,
               let fpId = fpId {
                // make a rest call
                let record = FpStatusRecord(
                    serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                    fpId: fpId,
                    birthDate: birthDateYYYMMDD,
                    extUserId: data.userIdentifier,
                    countryCode: data.countryCode
                )
                PrivoInternal.rest.processBirthDate(data: record) { [weak self] r in
                    if let response = r,
                       let status = self?.toStatus(response.action) {
                        let event = AgeGateEvent(
                            status: status,
                            userIdentifier: data.userIdentifier,
                            agId: response.ageGateIdentifier
                        )
                        if (response.action == AgeGateAction.Consent || response.action == AgeGateAction.IdentityVerify || response.action == AgeGateAction.AgeVerify) {
                            self?.runAgeGate(
                                data,
                                lastEvent: event,
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
    internal func recheckAgeGateByBirthDay(
        _ data: CheckAgeData,
        lastEvent: AgeGateEvent,
        completionHandler: @escaping (AgeGateEvent?) -> Void
    ) {
            if let birthDateYYYMMDD = data.birthDateYYYYMMDD,
               let agId = lastEvent.agId {
                // make a rest call
                let record = RecheckStatusRecord(
                    serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                    agId: agId,
                    birthDate: birthDateYYYMMDD,
                    countryCode: data.countryCode
                )
                PrivoInternal.rest.processRecheck(data: record) { [weak self] r in
                    if let response = r,
                       let status = self?.toStatus(response.action) {
                        let event = AgeGateEvent(
                            status: status,
                            userIdentifier: data.userIdentifier,
                            agId: agId
                        )
                        if (response.action == AgeGateAction.Consent || response.action == AgeGateAction.IdentityVerify || response.action == AgeGateAction.AgeVerify) {
                            self?.runAgeGate(
                                data,
                                lastEvent: event,
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
    
    internal func runAgeGate(
        _ data: CheckAgeData,
        lastEvent: AgeGateEvent?,
        recheckRequired: Bool,
        completionHandler: @escaping (AgeGateEvent?) -> Void
    ) {
        
        prepareSettings(data.userIdentifier) { (settings, fpId)  in
            
            guard let settings = settings else {
                completionHandler(nil)
                return
            }
            
            let agId = lastEvent?.agId;
            
            let ageGateData = CheckAgeStoreData(
                serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                settings: settings,
                userIdentifier: data.userIdentifier,
                countryCode: data.countryCode,
                birthDateYYYYMMDD: data.birthDateYYYYMMDD,
                redirectUrl: PrivoInternal.configuration.ageGatePublicUrl.withPath("/index.html#/age-gate-loading")!.absoluteString,
                agId: agId,
                fpId: fpId
            )
            UIApplication.shared.showView(false) {
                AgeGateView(
                    ageGateData : ageGateData,
                    targetPage: self.getStatusTargetPage(lastEvent?.status, recheckRequired: recheckRequired),
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
    
    internal func getFpId(completionHandler: @escaping (String?) -> Void) {
        if let fpId = keychain.get(FP_ID_KEY) {
            completionHandler(fpId)
        } else {
            if let fingerprint = try? DeviceFingerprint() {
                PrivoInternal.rest.generateFingerprint(fingerprint: fingerprint) { [weak self] r in
                    if let id = r?.id,
                       let fpIdKey = self?.FP_ID_KEY {
                        self?.keychain.set(key: fpIdKey, value: id)
                    }
                    completionHandler(r?.id)
                }
            } else {
                completionHandler(nil)
            }
        }
    }
    
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
                return AgeGateStatus.AgeVerified
            default:
                return AgeGateStatus.Undefined
        }
    }
    
}

struct PrivoAgeGateState {
    var isPresented = false
    var inProgress = true
    var privoStateId: String? = nil
}


struct AgeGateView : View {
    @State var state: PrivoAgeGateState = PrivoAgeGateState()
    let ageGateData: CheckAgeStoreData?
    let targetPage:  String
    let onFinish: ((Array<AgeGateEvent>) -> Void)

    private func getConfig(_ stateId: String) -> WebviewConfig {
        let ageGateUrl = PrivoInternal.configuration.ageGatePublicUrl
             .withPath("/index.html")?
             .withQueryParam(name: "privo_age_gate_state_id", value: stateId)?
             .withPath("#/\(targetPage)")
         return WebviewConfig(
             url: ageGateUrl!,
             showCloseIcon: false,
             finishCriteria: "age-gate-loading",
             onFinish: { url in
                 if let items = URLComponents(string: url)?.queryItems,
                    let eventId = items.first(where: {$0.name == "privo_age_gate_events_id"})?.value {
                     state.inProgress = true
                     PrivoInternal.rest.getObjectFromTMPStorage(key: eventId) { (events: Array<AgeGateEventInternal>?) in
                         let publicEvents = events?.map { $0.toEvent() }.compactMap { $0 }
                         finishView(publicEvents)
                     }
                 } else {
                     finishView(nil)
                 }
             },
             onClose: {
                 finishView(nil)
             }
         )
        
    }
    func showView() {
        if let ageGateData = ageGateData {
            state.inProgress = true
            PrivoInternal.rest.addObjectToTMPStorage(value: ageGateData) { id in
                if (id != nil) {
                    self.state.isPresented = true
                    self.state.privoStateId = id
                }
                state.inProgress = false
            }
        }
    }
    private func finishView(_ events: Array<AgeGateEvent>?) {
        state.inProgress = false
        state.privoStateId = nil
        
        if (state.isPresented == true) {
            state.isPresented = false
            onFinish(events ?? [AgeGateEvent(status: AgeGateStatus.Canceled, userIdentifier: nil, agId: nil)])
        }
    }
    
    public var body: some View {
        LoadingView(isShowing: $state.inProgress) {
            VStack {
                if (state.privoStateId != nil) {
                    ModalWebView(isPresented: $state.isPresented,  config: getConfig(state.privoStateId!))
                }
            }.onDisappear {
                finishView(nil)
            }
        }.onAppear {
            showView()
        }
    }
}
