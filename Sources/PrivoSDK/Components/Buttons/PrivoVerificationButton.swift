import SwiftUI

public struct PrivoVerificationButton<Label>:View where Label:View {
    
    //MARK: - Private properties
    
    @State private var state = PrivoVerificationState()
    private let verification = PrivoVerificationService()

    //MARK: - Internal properties
    
    public var profile: UserVerificationProfile?
    
    //MARK: - Private properties
    
    let label: Label
    var closeIcon: Image?
    let onFinish: (([VerificationEvent]) -> Void)?
    
    //MARK: - Public initialisers
    
    public init(@ViewBuilder label: () -> Label, profile: UserVerificationProfile? = nil, onFinish: (([VerificationEvent]) -> Void)? = nil, closeIcon: (() -> Image)? = nil) {
        if let profile = profile {
            self.profile = profile
        }
        self.label = label()
        self.closeIcon = closeIcon?()
        self.onFinish = onFinish
    }
    
    //MARK: - Internal functions
    
    func showView() {
        self.state.isPresented = true
    }
    
    //MARK: - Public functions
    
    public var body: some View {
        return Button {
            showView()
        } label: {
            label
        }.sheet(isPresented: $state.isPresented) {
            PrivoVerificationView(state: $state, profile: profile, closeIcon: closeIcon, onFinish: onFinish).clearModalBackground()
        }
    }
    
}
