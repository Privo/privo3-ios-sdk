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

    var closeIcon: Image?
    let onFinish: ((Array<VerificationEvent>) -> Void)?

    private func getConfig() -> WebviewConfig? {
        if let stateId = state.privoStateId,
           let verificationUrl = PrivoInternal.configuration.verificationUrl
                .withPath("/index.html")?
                .withQueryParam(name: "privo_state_id", value: stateId)?
                .withPath("#/intro") {
            return WebviewConfig(
                url: verificationUrl,
                showCloseIcon: false,
                printCriteria: "/print",
                finishCriteria: "verification-loading",
                onFinish: { url in
                    if let items = URLComponents(string: url)?.queryItems,
                       let eventId = items.first(where: {$0.name == "privo_events_id"})?.value {
                        PrivoInternal.rest.getObjectFromTMPStorage(key: eventId) { (events: Array<VerificationEvent>?) in
                            state.isPresented = false
                            onFinish?(events ?? Array())
                        }
                    } else {
                        state.isPresented = false
                        onFinish?(Array())
                    }
                })
        }
        return nil
    }
    
    public var body: some View {
        if let config = getConfig() {
            ModalWebView(isPresented: $state.isPresented,  config:config)
        }
    }
}
struct VerificationStateView : View {
    @State private var state = PrivoVerificationState()
    private let verification = InternalPrivoVerification()

    let profile: UserVerificationProfile?
    let onClose: () -> Void
    let onFinish: ((Array<VerificationEvent>) -> Void)?
    
    public var body: some View {
        VerificationView(state: $state.onChange({ s in
            if (s.isPresented == false) {
                onClose()
            }
        }), onFinish: { e in
            self.state.isPresented = false
            onFinish?(e)
        }).onAppear {
            verification.storeState(profile: profile) { id in
                self.state.privoStateId = id
                self.state.isPresented = true
            }
        }
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


