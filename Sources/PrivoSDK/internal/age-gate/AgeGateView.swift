//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 07.10.2022.
//

import Foundation
import SwiftUI

fileprivate struct PrivoAgeGateState {
    var isPresented = false
    var inProgress = true
    var privoStateId: String? = nil
}


struct AgeGateView : View {
    @State fileprivate var state: PrivoAgeGateState = PrivoAgeGateState()
    let ageGateData: CheckAgeStoreData?
    let targetPage:  String
    let onFinish: ((Array<AgeGateEvent>) -> Void)

    private func getConfig(_ stateId: String) -> WebviewConfig {
        let ageGateUrl = PrivoInternal.configuration.ageGatePublicUrl
             .withPath("/index.html")?
             .withQueryParam(name: "privo_age_gate_state_id", value: stateId)?
             .withQueryParam(name: "service_identifier", value: PrivoInternal.settings.serviceIdentifier)?
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
                         let nonCanceledEvents = publicEvents?.filter { $0.status != AgeGateStatus.Canceled };
                         let resultEvents = (nonCanceledEvents?.isEmpty ?? true) ? publicEvents : nonCanceledEvents
                         finishView(resultEvents)
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
            onFinish(events ?? [AgeGateEvent(status: AgeGateStatus.Canceled, userIdentifier: nil, agId: nil, ageRange: nil)])
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
