import SwiftUI

struct PrivoRegisterStateView : View {
    
    //MARK: - Internal properties
    
    @State var isPresented: Bool = true
    let onClose: (() -> Void)
    let onFinish: (() -> Void)?
    
    //MARK: - Body builder
    
    public var body: some View {
        PrivoRegisterView(isPresented: $isPresented.onChange({ presented in
            if !presented { onClose() }
        }), onFinish: onFinish)
    }
    
}
