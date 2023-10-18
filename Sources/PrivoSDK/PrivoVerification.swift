//
//  File.swift
//
//
//  Created by alex slobodeniuk on 14.06.2021.
//

import SwiftUI


public struct PrivoVerificationButton<Label> : View where Label : View {
    
    //MARK: - Public properties
    
    public var profile: UserVerificationProfile?
    
    //MARK: - Internal properties
    
    let label: Label
    var closeIcon: Image?
    let onFinish: (([VerificationEvent]) -> Void)?
    
    //MARK: - Private properties
    
    @State
    private var state: PrivoVerificationState
    private let verification: InternalPrivoVerification
    
    //MARK: - Public initialisers
    
    public init(@ViewBuilder label: () -> Label,
                profile: UserVerificationProfile? = nil,
                onFinish: (([VerificationEvent]) -> Void)? = nil,
                closeIcon: (() -> Image)? = nil) {
        if let profile = profile {
            self.profile = profile
        }
        self.label = label()
        self.closeIcon = closeIcon?()
        self.onFinish = onFinish
        self._state = .init(wrappedValue: .init())
        self.verification = .init()
    }
    
    //MARK: - Body builder
    
    public var body: some View {
        return Button {
            showView()
        } label: {
            label
        }.sheet(isPresented: $state.isPresented) {
            VerificationView(state: $state,
                             profile: profile,
                             closeIcon: closeIcon,
                             onFinish: onFinish)
        }
    }
    
    //MARK: - Internal properties
    
    func showView() {
        self.state.isPresented = true
    }
    
}


public class PrivoVerification {
    
    //MARK: - Private properties
    
    private let verification: InternalPrivoVerification
    private let app: UIApplication
    
    //MARK: - Public initialisers
    
    public init(app: UIApplication = .shared) {
        verification = InternalPrivoVerification()
        self.app = app
    }
    
    //MARK: - Public functions
    
    public func showVerification(_ profile: UserVerificationProfile?,
                                 completion: (([VerificationEvent]) -> Void)?) {
        Task.init(priority: .userInitiated) { @MainActor in
            app.showView(false) {
                VerificationStateView( profile: profile,
                                       onClose: { [weak self] in
                    guard let self = self else { return }
                    Task.init(priority: .userInitiated) { @MainActor in
                        self.app.dismissTopView()
                    }
                })
                { [weak self] e in
                    guard let self = self else { return }
                    Task.init(priority: .userInitiated) { @MainActor in
                        self.app.dismissTopView()
                        completion?(e)
                    }
                }
            }
        }
    }
}
