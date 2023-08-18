import SwiftUI

struct PrivoAgeVerificationView : View {
    
    //MARK: - Internal properties
    
    @State var state = PrivoAgeVerificationState()
    let ageVerificationData: AgeVerificationStoreData?
    let onFinish: ((Array<AgeVerificationEventInternal>) -> Void)
    
    private let api: Rest = .shared
    
    //MARK: - Body builder
    
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
        if let ageVerificationData = ageVerificationData {
            state.inProgress = true
            PrivoService.rest.addObjectToTMPStorage(value: ageVerificationData) { id in
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
        let ageGateUrl = PrivoService.configuration.ageVerificationPublicUrl
             .withPath("/index.html")?
             .withQueryParam(name: "privo_state_id", value: stateId)?
             .withQueryParam(name: "service_identifier", value: PrivoService.settings.serviceIdentifier)?
             .withPath("#/intro")
        return .init(url: ageGateUrl!,
                     showCloseIcon: false,
                     finishCriteria: "age-verification-loading",
                     onFinish: { url in
                if let items = URLComponents(string: url)?.queryItems,
                   let eventId = items.first(where: {$0.name == "privo_age_verification_events_id"})?.value {
                     state.inProgress = true
                     api.getObjectFromTMPStorage(key: eventId) { (events: Array<AgeVerificationEventInternal>?) in
                         finishView(events)
                     }
                } else {
                    finishView(nil)
                }
            }, onClose: {
            finishView(nil)
        })
    }
    
    private func finishView(_ events: Array<AgeVerificationEventInternal>?) {
        state.inProgress = false
        state.privoStateId = nil
        if state.isPresented {
            state.isPresented = false
            onFinish(events ?? [.init(status: .Canceled, profile: nil, ageVerificationId: nil)])
        }
    }
    
}
