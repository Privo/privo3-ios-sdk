//
//  File.swift
//
//
//  Created by alex slobodeniuk on 14.06.2021.
//

import SwiftUI

public struct PrivoVerificationView<Label> : View where Label : View {
    @State private var presentingVerification = false
    @State private var privoStateId: String? = nil

    public var profile: UserVerificationProfile = UserVerificationProfile()
    let label: Label
    var closeIcon: Label?
    let onFinish: ((Array<VerificationEvent>) -> Void)?
    
    public init(@ViewBuilder label: () -> Label, onFinish: ((Array<VerificationEvent>) -> Void)? = nil, closeIcon: (() -> Label)? = nil, profile: UserVerificationProfile? = nil) {
        if let profile = profile {
            self.profile = profile
        }
        self.label = label()
        self.closeIcon = closeIcon?()
        self.onFinish = onFinish
    }
    public var body: some View {
        let redirectUrl = "localhost"
        var verificationUrl = PrivoInternal.configuration.verificationUrl
        verificationUrl.appendQueryParam(name: "privo_state_id", value: redirectUrl)
        let config = WebviewConfig(url: verificationUrl, finishCriteria: redirectUrl, onFinish: { url in
            if let items = URLComponents(string: url)?.queryItems,
               let eventId = items.first(where: {$0.name == "privo_events_id"})?.value {
                PrivoInternal.rest.getObjectFromTMPStorage(key: eventId) { (events: Array<VerificationEvent>?) in
                    presentingVerification = false
                    onFinish?(events ?? Array())
                }
            } else {
                presentingVerification = false
                onFinish?(Array())
            }
        })
    
        return Button {
            if let apiKey = PrivoInternal.settings.apiKey {
                let data = VerificationData(profile: self.profile, config: VerificationConfig(apiKey: apiKey, siteIdentifier: PrivoInternal.settings.serviceIdentifier), redirectUrl: redirectUrl)
                PrivoInternal.rest.addObjectToTMPStorage(value: data) { id in
                    privoStateId = id
                    presentingVerification = true
                }
            }
        } label: {
            label
        }.sheet(isPresented: $presentingVerification) {
            ModalWebView(isPresented: self.$presentingVerification,  config: config)
        }
    }
}

