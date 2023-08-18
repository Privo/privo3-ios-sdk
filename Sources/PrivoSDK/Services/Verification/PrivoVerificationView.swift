import SwiftUI

struct PrivoVerificationView: View {
    
    //MARK: - Internal properties
    
    @Binding var state: PrivoVerificationState
    let profile: UserVerificationProfile?
    var closeIcon: Image?
    let onFinish: ((Array<VerificationEvent>) -> Void)?
    
    //MARK: - Private properties
    
    private let verification = PrivoVerificationService()
    private let api: Rest = .shared
    
    //MARK: - Body builder
    
    public var body: some View {
        LoadingView(isShowing: $state.inProgress) {
            VStack {
                if (state.privoStateId != nil) {
                    ModalWebView(isPresented: $state.isPresented,  config: getConfig(state.privoStateId!))
                }
            }.onDisappear {
                finishView(nil, isOnDisappear: true)
            }
        }.onAppear {
            showView()
        }
    }
    
    //MARK: - Internal functions
    
    func showView() {
        state.isFinished = false
        state.inProgress = true
        verification.storeState(profile: profile) { id in
            if (id != nil) {
                self.state.isPresented = true
                self.state.privoStateId = id
            }
            state.inProgress = false
        }
    }
    
    //MARK: - Private functions

    private func getConfig(_ stateId: String) -> WebviewConfig {
        let verificationUrl = PrivoService.configuration.verificationUrl
             .withPath("/index.html")?
             .withQueryParam(name: "privo_state_id", value: stateId)?
             .withQueryParam(name: "service_identifier", value: PrivoService.settings.serviceIdentifier)?
             .withPath("#/intro")
        return .init(url: verificationUrl!,
                     showCloseIcon: false,
                     printCriteria: "/print",
                     finishCriteria: "verification-loading",
                     onFinish: { url in
            if let items = URLComponents(string: url)?.queryItems,
               let eventId = items.first(where: {$0.name == "privo_events_id"})?.value {
                 state.inProgress = true
                 api.getObjectFromTMPStorage(key: eventId) { (events: Array<VerificationEvent>?) in
                    if let errorEvent = events?.first (where: { $0.event == VerificationEventType.verifyError  }) {
                        let customError = "Event error: code - \(String(describing: errorEvent.errorCode)) message - \(String(describing: errorEvent.errorMessage))"
                        api.trackCustomError(customError)
                    }
                     finishView(events)
                 }
            } else {
                finishView(nil)
            }
        })
    }
    
    private func finishView(_ verificationEvents: Array<VerificationEvent>?, isOnDisappear: Bool = false) {
        if (state.isFinished == false) { //Remove
            state.privoStateId = nil
            state.isPresented = false
            state.isFinished = true
            state.inProgress = false
            if (isOnDisappear && verificationEvents == nil) { //Remove
                let events = self.verification.getCancelEvents()
                onFinish?(events)
            } else {
                onFinish?(verificationEvents ?? Array())
                
            }
        }
    }
    
}
