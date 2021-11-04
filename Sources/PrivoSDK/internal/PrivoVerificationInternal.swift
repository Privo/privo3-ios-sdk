//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 30.08.2021.
//

import SwiftUI


struct PrivoVerificationState {
    var isPresented = false
    var privoStateId: String? = nil
}

struct VerificationView : View {
    @Binding var state: PrivoVerificationState
    @State var inProgress = true
    let profile: UserVerificationProfile?

    var closeIcon: Image?
    let onFinish: ((Array<VerificationEvent>) -> Void)?
    private let verification = InternalPrivoVerification()

    private func finish(_ events: Array<VerificationEvent>?) {
        state.privoStateId = nil
        state.isPresented = false
        inProgress = false
        onFinish?(events ?? Array())
    }
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
                    inProgress = true
                     PrivoInternal.rest.getObjectFromTMPStorage(key: eventId) { (events: Array<VerificationEvent>?) in
                        if let errorEvent = events?.first (where: { $0.event == VerificationEventType.verifyError  }) {
                            let customError = "Event error: code - \(String(describing: errorEvent.errorCode)) message \(String(describing: errorEvent.errorMessage))"
                            PrivoInternal.rest.trackCustomError(customError)
                        }
                        finish(events)
                     }
                 } else {
                    finish(nil)
                 }
             })
    }
    func showView() {
        verification.storeState(profile: profile) { id in
            if (id != nil) {
                self.state.isPresented = true
                self.state.privoStateId = id
            }
            inProgress = false
        }
    }
    
    public var body: some View {
        LoadingView(isShowing: $inProgress) {
            VStack {
                if (state.privoStateId != nil) {
                    ModalWebView(isPresented: $state.isPresented,  config: getConfig(state.privoStateId!))
                }
            }
        }.onAppear {
            showView()
        }
    }
}
struct VerificationStateView : View {
    @State private var state = PrivoVerificationState()

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
            profile: profile, onFinish: { e in
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
    
}


