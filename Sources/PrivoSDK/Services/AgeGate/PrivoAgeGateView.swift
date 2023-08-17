import Foundation
import SwiftUI

fileprivate struct PrivoAgeGateState {
    var isPresented = false
    var inProgress = true
    var privoStateId: String? = nil
}

struct PrivoAgeGateView : View {
    
    //MARK: - Internal properties
    
    let ageGateData: CheckAgeStoreData?
    let targetPage:  String
    var finishCriteria: String = "age-gate-loading"
    let onFinish: ((Array<AgeGateEvent>) async -> Void)?
    
    //MARK: - Private properties
    
    @State
    fileprivate var state: PrivoAgeGateState = PrivoAgeGateState()
    
    //MARK: - Boyd builder
    
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
    
    //MARK: - Internal functions
    
    func showView() {
        if let ageGateData = ageGateData {
            state.inProgress = true
            PrivoService.rest.addObjectToTMPStorage(value: ageGateData) { id in
                if (id != nil) {
                    self.state.isPresented = true
                    self.state.privoStateId = id
                }
                state.inProgress = false
            }
        }
    }
    
    //MARK: - Private functions

    private func getConfig(_ stateId: String) -> WebviewConfig {
        let ageGateUrl = PrivoService.configuration.ageGatePublicUrl
             .withPath("/index.html")?
             .withQueryParam(name: "privo_age_gate_state_id", value: stateId)?
             .withQueryParam(name: "service_identifier", value: PrivoService.settings.serviceIdentifier)?
             .withPath("#/\(targetPage)")
        return .init(url: ageGateUrl!,
                     showCloseIcon: false,
                     finishCriteria: finishCriteria,
                     onFinish: { url in
                 guard let items = URLComponents(string: url)?.queryItems,
                       let eventId = items.first(where: {$0.name == "privo_age_gate_events_id"})?.value else {
                     finishView(nil)
                     return
                 }
                 state.inProgress = true
                 PrivoService.rest.getObjectFromTMPStorage(key: eventId) { (events: Array<AgeGateEventInternal>?) in
                     let publicEvents = events?.map { $0.toEvent(nickname: ageGateData?.nickname) }.compactMap { $0 }
                     let nonCanceledEvents = publicEvents?.filter { $0.status != AgeGateStatus.Canceled };
                     let resultEvents = (nonCanceledEvents?.isEmpty ?? true) ? publicEvents : nonCanceledEvents
                     finishView(resultEvents)
                 }
             },
             onClose: {
                 finishView(nil)
             }
         )
        
    }
    
    private func finishView(_ events: Array<AgeGateEvent>?) {
        state.inProgress = false
        state.privoStateId = nil
        if (state.isPresented) {
            state.isPresented = false
            Task.init {
                await onFinish?(events ?? [AgeGateEvent(
                    status: AgeGateStatus.Canceled,
                    userIdentifier: nil,
                    nickname: nil,
                    agId: nil,
                    ageRange: nil,
                    countryCode: nil
                )])
            }
        }
    }
    
}
