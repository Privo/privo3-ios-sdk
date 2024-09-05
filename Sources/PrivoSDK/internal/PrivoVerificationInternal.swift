import SwiftUI

struct PrivoVerificationState {
    var inProgress = true
    var isPresented = false
    var isFinished = false
    var privoStateId: String? = nil
}

struct VerificationView : View {
    
    //MARK: - Internal properties
    
    @Binding var state: PrivoVerificationState
    let profile: UserVerificationProfile?
    var closeIcon: Image?
    let onFinish: ((Array<VerificationEvent>) -> Void)?
    
    //MARK: - Private properties
    
    private let verification = InternalPrivoVerification()
    private let api: Restable
    
    init(state: Binding<PrivoVerificationState>,
         profile: UserVerificationProfile?,
         closeIcon: Image? = nil,
         onFinish: ((Array<VerificationEvent>) -> Void)?,
         api: Restable = Rest.shared) {
        self._state = state
        self.profile = profile
        self.closeIcon = closeIcon
        self.onFinish = onFinish
        self.api = api
    }

    private func getConfig(_ stateId: String) -> WebviewConfig {
        let verificationUrl = PrivoInternal.configuration.verificationUrl
             .withPath("/index.html")
             .withQueryParam(name: "privo_state_id", value: stateId)
             .withQueryParam(name: "service_identifier", value: PrivoInternal.settings.serviceIdentifier)
             .withPath("#/intro")
        return .init(url: verificationUrl,
                     showCloseIcon: false,
                     printCriteria: "/print",
                     finishCriteria: "verification-loading",
                     onFinish: { url in
                 guard let items = URLComponents(string: url)?.queryItems,
                       let eventId = items.first(where: {$0.name == "privo_events_id"})?.value else {
                     finishView(nil)
                     return
                 }
                 state.inProgress = true
                 api.getObjectFromTMPStorage(key: eventId) { (events: [VerificationEvent]?) in
                    if let errorEvent = events?.first (where: { $0.event == VerificationEventType.verifyError }) {
                        let customError = "Event error: code - \(String(describing: errorEvent.errorCode)) message - \(String(describing: errorEvent.errorMessage))"
                        PrivoInternal.rest.trackCustomError(customError)
                    }
                    finishView(events)
                 }
        })
    }
    func showView() {
        state.isFinished = false
        state.inProgress = true
        verification.storeState(profile: profile) { id in
            if id != nil {
                state.isPresented = true
                state.privoStateId = id
            }
            state.inProgress = false
        }
    }
    
    private func finishView(_ verificationEvents: Array<VerificationEvent>?, isOnDisappear: Bool = false) {
        guard !state.isFinished else { return }
        state.privoStateId = nil
        state.isPresented = false
        state.isFinished = true
        state.inProgress = false
        if (isOnDisappear && verificationEvents == nil) {
            let events = self.verification.getCancelEvents()
            onFinish?(events)
        } else {
            onFinish?(verificationEvents ?? [])
        }
    }
    
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
}
struct VerificationStateView : View {
    @State private var state = PrivoVerificationState( inProgress: true, isPresented: true, isFinished: false, privoStateId: nil)

    let profile: UserVerificationProfile?
    let onClose: () -> Void
    let onFinish: ((Array<VerificationEvent>) -> Void)?
    
    public var body: some View {
        VerificationView(
            state: $state.onChange({ s in
                if (s.isPresented == false) {
                    onClose()
                }
            }),
            profile: profile,
            onFinish: { e in
                self.state.isPresented = false
                onFinish?(e)
            }
        )
    }
}

class InternalPrivoVerification {
    
    private let redirectUrl = PrivoInternal.configuration.verificationUrl.withPath("/#/verification-loading").absoluteString
    private let api: Restable = Rest.shared
    
    private var userSessions: [String: String] = [:]

    func storeState(profile: UserVerificationProfile?, completion: @escaping (String?) -> Void ) -> Void {
        guard let apiKey = PrivoInternal.settings.apiKey else { return }
        let data = VerificationData(profile: profile ?? .init(),
                                    config: .init(apiKey: apiKey, siteIdentifier: PrivoInternal.settings.serviceIdentifier),
                                    redirectUrl: redirectUrl)
        api.addObjectToTMPStorage(value: data, completionHandler: completion)
    }
    
    func getCancelEvents() -> [VerificationEvent] {
        [
            .init(event: .verifyInitialized, result: nil, data: nil, errorCode: nil, errorMessage: nil),
            .init(event: .verifyCancel, result: nil, data: nil, errorCode: nil, errorMessage: nil)
        ]
    }
    

    
    func getUserLimits (externalUserId: String, completionHandler: @escaping (UserLimits?) -> Void) {
        let serviceIdentifier = PrivoInternal.settings.serviceIdentifier
        if let sessionIdentifier = userSessions[externalUserId] {
            api.checkUserLimits(serviceIdentifier: serviceIdentifier, sessionIdentifier: sessionIdentifier, limitType: LimitType.IV, completionHandler: completionHandler)
        } else {
            api.createUserSession(serviceIdentifier: serviceIdentifier, externalUserId: externalUserId) { [weak self] sessionIdentifier in
                if let sessionIdentifier = sessionIdentifier {
                    self?.userSessions[externalUserId] = sessionIdentifier
                    self?.api.checkUserLimits(serviceIdentifier: serviceIdentifier, sessionIdentifier: sessionIdentifier, limitType: LimitType.IV, completionHandler: completionHandler)
                } else {
                    completionHandler(nil)
                }
            }
        }
        
    
    }
    
}


