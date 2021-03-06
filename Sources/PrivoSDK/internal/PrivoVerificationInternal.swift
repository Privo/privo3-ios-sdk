//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 30.08.2021.
//

import SwiftUI


struct PrivoVerificationState {
    var inProgress = true
    var isPresented = false
    var isFinished = false
    var privoStateId: String? = nil
}

struct VerificationView : View {
    @Binding var state: PrivoVerificationState
    let profile: UserVerificationProfile?
    var closeIcon: Image?
    let onFinish: ((Array<VerificationEvent>) -> Void)?
    private let verification = InternalPrivoVerification()

    private func getConfig(_ stateId: String) -> WebviewConfig {
        let verificationUrl = PrivoInternal.configuration.verificationUrl
             .withPath("/index.html")?
             .withQueryParam(name: "privo_state_id", value: stateId)?
             .withPath("#/intro")
         return WebviewConfig(
             url: verificationUrl!,
             showCloseIcon: false,
             printCriteria: "/print",
             finishCriteria: "verification-loading",
             onFinish: { url in
                 if let items = URLComponents(string: url)?.queryItems,
                    let eventId = items.first(where: {$0.name == "privo_events_id"})?.value {
                     state.inProgress = true
                     PrivoInternal.rest.getObjectFromTMPStorage(key: eventId) { (events: Array<VerificationEvent>?) in
                        if let errorEvent = events?.first (where: { $0.event == VerificationEventType.verifyError  }) {
                            let customError = "Event error: code - \(String(describing: errorEvent.errorCode)) message - \(String(describing: errorEvent.errorMessage))"
                            PrivoInternal.rest.trackCustomError(customError)
                        }
                         finishView(events)
                     }
                 } else {
                     finishView(nil)
                 }
             })
    }
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

struct InternalPrivoVerification {
    private let redirectUrl = PrivoInternal.configuration.verificationUrl.withPath("/#/verification-loading")!.absoluteString

    func storeState(profile: UserVerificationProfile?, completion: @escaping (String?) -> Void ) -> Void {
        if let apiKey = PrivoInternal.settings.apiKey {
            let data = VerificationData(profile: profile ?? UserVerificationProfile(), config: VerificationConfig(apiKey: apiKey, siteIdentifier: PrivoInternal.settings.serviceIdentifier), redirectUrl: redirectUrl)
            PrivoInternal.rest.addObjectToTMPStorage(value: data, completionHandler: completion)
        }
    }
    
    func getCancelEvents() -> Array<VerificationEvent> {
        [
            VerificationEvent(event: VerificationEventType.verifyInitialized, result: nil, data: nil, errorCode: nil, errorMessage: nil),
            VerificationEvent(event: VerificationEventType.verifyCancel, result: nil, data: nil, errorCode: nil, errorMessage: nil)
        ]
    }
    
}


