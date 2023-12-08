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
    
    //MARK: - Internal properties
    
    let ageGateData: CheckAgeStoreData?
    let targetPage:  String
    var finishCriteria: String = "age-gate-loading"
    let onFinish: ((Array<AgeGateEvent>) async -> Void)?
    
    //MARK: - Private properties
    
    @State
    fileprivate var state: PrivoAgeGateState = PrivoAgeGateState()
    private let api: Restable = Rest.shared
    
    //MARK: - Body builder
    
    public var body: some View {
        LoadingView(isShowing: $state.inProgress) {
            VStack {
                if state.privoStateId != nil {
                    ModalWebView(isPresented: $state.isPresented, config: getConfig(state.privoStateId!))
                }
            }.onDisappear {
                finishView(nil)
            }
        }.onAppear {
            showView()
        }
    }
    
    //MARK: - Internal functions
    
    func showView() {
        guard let ageGateData = ageGateData else { return }
        state.inProgress = true
        api.addObjectToTMPStorage(value: ageGateData) { id in
            if id != nil {
                state.isPresented = true
                state.privoStateId = id
            }
            state.inProgress = false
        }
    }

    //MARK: - Private functions
    
    private func getConfig(_ stateId: String) -> WebviewConfig {
        let ageGateUrl = PrivoInternal.configuration.ageGatePublicUrl
             .withPath("/index.html")?
             .withQueryParam(name: "privo_age_gate_state_id", value: stateId)?
             .withQueryParam(name: "service_identifier", value: PrivoInternal.settings.serviceIdentifier)?
             .withPath("#/\(targetPage)")
        return .init(url: ageGateUrl!,
                     showCloseIcon: false,
                     finishCriteria: finishCriteria,
                     onFinish: { url in
                 if let items = URLComponents(string: url)?.queryItems,
                    let eventId = items.first(where: {$0.name == "privo_age_gate_events_id"})?.value {
                     state.inProgress = true
                     api.getObjectFromTMPStorage(key: eventId) { (events: Array<AgeGateEventInternal>?) in
                         let publicEvents = events?.map { $0.toEvent(nickname: ageGateData?.nickname) }.compactMap { $0 }
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
             })
    }
    
    private func finishView(_ events: Array<AgeGateEvent>?) {
        state.inProgress = false
        state.privoStateId = nil
        guard state.isPresented else { return }
        state.isPresented = false
        Task.init {
            await onFinish?(events ?? [.init(
                status: .Canceled,
                userIdentifier: nil,
                nickname: nil,
                agId: nil,
                ageRange: nil,
                countryCode: nil
            )])
        }
    }
    
}
