import SwiftUI

struct PrivoVerificationStateView : View {
    
    //MARK: - Internal properties
    
    let profile: UserVerificationProfile?
    let onClose: () -> Void
    let onFinish: ((Array<VerificationEvent>) -> Void)?
    
    //MARK: - Private  properties
    
    @State
    private var state = PrivoVerificationState(inProgress: true, isPresented: true, isFinished: false, privoStateId: nil)

    //MARK: - Body builder
    
    public var body: some View {
        PrivoVerificationView(
            state: $state.onChange({ s in
                if !s.isPresented {
                    onClose()
                }
            }),
            profile: profile,
            onFinish: { e in
                state.isPresented = false
                onFinish?(e)
            }
        )
    }
}
