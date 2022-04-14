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
    private let AGE_EVENT_KEY = "AgeGateEvent"
    private let keychain = PrivoKeychain()
    private var serviceSettings: AgeServiceSettings? = nil
    
    internal init() {
        PrivoInternal.rest.getAgeServiceSettings(serviceIdentifier: PrivoInternal.settings.serviceIdentifier) { s in
            self.serviceSettings = s
        }
    }
    
    internal func storeAgeGateEvent(_ event: AgeGateEvent) {
        if let jsonData = try? JSONEncoder().encode(event) {
            let jsonString = String(decoding: jsonData, as: UTF8.self)
            keychain.set(key: AGE_EVENT_KEY, value: jsonString)
        }
    }
    
    internal func getAgeGateEvent(completionHandler: @escaping (AgeGateEvent?) -> Void) {
        if let jsonString = keychain.get(AGE_EVENT_KEY),
           let jsonData = jsonString.data(using: .utf8),
           let value = try? JSONDecoder().decode(AgeGateEvent.self, from: jsonData) {
             completionHandler(value)
         } else {
             completionHandler(nil)
         }
    }
    
    internal func getStatusEvent(_ userIdentifier: String?, completionHandler: @escaping (AgeGateEvent) -> Void) {
        getAgeGateEvent() { lastEvent in
            self.getFpId { fpId in
                let agId = lastEvent?.userIdentifier == userIdentifier ? lastEvent?.agId : nil;
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
                        status: AgeGateStatus.Undefined,
                        userIdentifier: userIdentifier,
                        agId: nil
                    ))
                }
            }
        }
    }
    
    internal func runAgeGateByBirthDay(_ data: CheckAgeData, completionHandler: @escaping (AgeGateEvent?) -> Void) {
        getFpId() { fpId in
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
                        completionHandler(event)
                    } else {
                        completionHandler(nil)
                    }
                }
            }
        }
    }
    
    private func prepareSettings(completionHandler: @escaping (AgeServiceSettings?,String?,AgeGateEvent?) -> Void) {
        var settings: AgeServiceSettings? = serviceSettings
        var fpId: String? = nil
        var lastEvent: AgeGateEvent? = nil
        
        let group = DispatchGroup()
        if (settings == nil) {
            group.enter()
            PrivoInternal.rest.getAgeServiceSettings(serviceIdentifier: PrivoInternal.settings.serviceIdentifier) { s in
                settings = s
                group.leave()
            }
        }
        group.enter()
        group.enter()
        getFpId() { r in
            fpId = r
            group.leave()
        }
        getAgeGateEvent() { event in
            lastEvent = event
            group.leave()
        }
        group.notify(queue: .main) {
            completionHandler(settings,fpId, lastEvent)
        }
        
        return ()
        
    }
    
    private func getAgeGateTargetPage (_ status: AgeGateStatus?) -> String {
        switch status {
            case .Pending:
                return "verification-pending";
            case .Blocked:
                return "sorry";
            default:
                return "dob";
        }
    };
    
    internal func runAgeGate(_ data: CheckAgeData, completionHandler: @escaping (AgeGateEvent?) -> Void) {
        
        prepareSettings() { (settings, fpId, lastEvent) in
            
            guard let settings = settings else {
                return
            }
            
            let agId = lastEvent?.userIdentifier == data.userIdentifier ? lastEvent?.agId : nil;
            let status = lastEvent?.userIdentifier == data.userIdentifier ? lastEvent?.status : nil;
            
            let ageGateData = CheckAgeStoreData(
                serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                settings: settings,
                userIdentifier: data.userIdentifier,
                countryCode: data.countryCode,
                redirectUrl: PrivoInternal.configuration.ageGatePublicUrl.withPath("/index.html#/age-gate-loading")!.absoluteString,
                agId: agId,
                fpId: fpId
            )
            let target = self.getAgeGateTargetPage(status)
            UIApplication.shared.showView(false) {
                AgeGateView(ageGateData : ageGateData, targetPage: target, onFinish: { events in
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
    
    internal func runAgeGateRecheck(_ data: RecheckAgeData, completionHandler: @escaping (AgeGateEvent?) -> Void) {
        
        prepareSettings() { (settings, fpId, lastEvent) in
            
            guard let settings = settings else {
                return
            }
            
            let agId = lastEvent?.userIdentifier == data.userIdentifier ? lastEvent?.agId : nil;
            
            if (agId == nil) {
                print("Previous status not found")
                return
            }
            
            let ageGateData = CheckAgeStoreData(
                serviceIdentifier: PrivoInternal.settings.serviceIdentifier,
                settings: settings,
                userIdentifier: data.userIdentifier,
                countryCode: data.countryCode,
                redirectUrl: PrivoInternal.configuration.ageGatePublicUrl.withPath("/index.html#/age-gate-loading")!.absoluteString,
                agId: agId,
                fpId: fpId
            )
            UIApplication.shared.showView(false) {
                AgeGateView(ageGateData : ageGateData, targetPage: "recheck", onFinish: { events in
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
                return AgeGateStatus.Pending
            case .Verify:
                return AgeGateStatus.Pending
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
        state.isPresented = false
        state.privoStateId = nil
        if let events = events {
            onFinish(events)
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
