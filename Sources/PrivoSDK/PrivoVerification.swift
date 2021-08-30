//
//  File.swift
//
//
//  Created by alex slobodeniuk on 14.06.2021.
//

import SwiftUI


public struct PrivoVerificationButton<Label> : View where Label : View {
    @State private var state = PrivoVerificationState()
    private let verification = InternalPrivoVerification()

    public var profile: UserVerificationProfile?
    let label: Label
    var closeIcon: Image?
    let onFinish: ((Array<VerificationEvent>) -> Void)?
    
    public init(@ViewBuilder label: () -> Label, profile: UserVerificationProfile? = nil, onFinish: ((Array<VerificationEvent>) -> Void)? = nil, closeIcon: (() -> Image)? = nil) {
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
            self.state.isPresented = true
        }
    }
    public var body: some View {
        return Button {
            showView()
        } label: {
            label
        }.sheet(isPresented: $state.isPresented) {
            VerificationView(state: $state, closeIcon: closeIcon, onFinish: onFinish)
        }
    }
}


public class PrivoVerification {
    public init() {}
    
    public func showVerification(_ profile: UserVerificationProfile?, completion: ((Array<VerificationEvent>) -> Void)?) {
        UIApplication.shared.showView {
            VerificationStateView(profile: profile, onClose: {
                UIApplication.shared.dismissTopView()
            }) { e in
                UIApplication.shared.dismissTopView()
                completion?(e)
            }
        }
    }
}
