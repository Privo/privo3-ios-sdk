//
//  File.swift
//
//
//  Created by alex slobodeniuk on 14.06.2021.
//

import SwiftUI


public struct PrivoVerificationState {
    var presentingVerification = false
    var privoStateId: String? = nil
}

private struct VerificationModal : View {
    @Binding fileprivate var state: PrivoVerificationState

    fileprivate var closeIcon: Image?
    fileprivate let onFinish: ((Array<VerificationEvent>) -> Void)?

    private func getConfig() -> WebviewConfig? {
        if let stateId = state.privoStateId,
           let verificationUrl = PrivoInternal.configuration.verificationUrl
                .withPath("/index.html")?
                .withQueryParam(name: "privo_state_id", value: stateId)?
                .withPath("/#/intro") {
            return WebviewConfig(
                url: verificationUrl,
                showCloseIcon: false,
                printCriteria: "/print",
                finishCriteria: "verification-loading",
                onFinish: { url in
                    if let items = URLComponents(string: url)?.queryItems,
                       let eventId = items.first(where: {$0.name == "privo_events_id"})?.value {
                        PrivoInternal.rest.getObjectFromTMPStorage(key: eventId) { (events: Array<VerificationEvent>?) in
                            state.presentingVerification = false
                            onFinish?(events ?? Array())
                        }
                    } else {
                        state.presentingVerification = false
                        onFinish?(Array())
                    }
                })
        }
        return nil
    }
    
    public var body: some View {
        if let config = getConfig() {
            ModalWebView(isPresented: $state.presentingVerification,  config:config)
        }
    }
}

public struct PrivoVerificationView<Label> : View where Label : View {
    @State fileprivate var state = PrivoVerificationState()
    private let verification = InternalPrivoVerification()

    public var profile: UserVerificationProfile?
    let label: Label
    var closeIcon: Image?
    let onFinish: ((Array<VerificationEvent>) -> Void)?
    
    public init(@ViewBuilder label: () -> Label, onFinish: ((Array<VerificationEvent>) -> Void)? = nil, closeIcon: (() -> Image)? = nil, profile: UserVerificationProfile? = nil) {
        if let profile = profile {
            self.profile = profile
        }
        self.label = label()
        self.closeIcon = closeIcon?()
        self.onFinish = onFinish
    }
    func showView() {
        verification.storeState(profile: profile) { id in
            self.state.privoStateId = id
            self.state.presentingVerification = true
        }
    }
    public var body: some View {
        return Button {
            showView()
        } label: {
            label
        }.sheet(isPresented: $state.presentingVerification) {
            VerificationModal(state: $state, closeIcon: closeIcon, onFinish: onFinish)
        }
    }
}


public class PrivoVerification {
    public init() {}
    @State var state = PrivoVerificationState()
    private let verification = InternalPrivoVerification()
    
    public func showVerificationModal(profile: UserVerificationProfile = UserVerificationProfile(), completion: ((Array<VerificationEvent>) -> Void)?) {
        verification.storeState(profile: profile) { [weak self] id in
            self?.state.privoStateId = id
            self?.state.presentingVerification = true
        }
        UIApplication.shared.showView {
            VerificationModal(state: self.$state, onFinish: completion)
        }
    }
}

fileprivate struct InternalPrivoVerification {
    private let redirectUrl = PrivoInternal.configuration.verificationUrl.withPath("/#/verification-loading")!.absoluteString

    func storeState(profile: UserVerificationProfile?, completion: @escaping (String?) -> Void ) -> Void {
        if let apiKey = PrivoInternal.settings.apiKey {
            let data = VerificationData(profile: profile ?? UserVerificationProfile(), config: VerificationConfig(apiKey: apiKey, siteIdentifier: PrivoInternal.settings.serviceIdentifier), redirectUrl: redirectUrl)
            PrivoInternal.rest.addObjectToTMPStorage(value: data, completionHandler: completion)
        }
    }
    
}
