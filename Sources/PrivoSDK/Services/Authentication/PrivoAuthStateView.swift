import SwiftUI

struct PrivoAuthStateView : View {
    
    //MARK: - Internal properties
    
    @State var isPresented: Bool = true
    let onClose: (() -> Void)
    let onFinish: ((String?) -> Void)?
    
    //MARK: - Body builder

    public var body: some View {
        PrivoAuthView(isPresented: $isPresented.onChange({ presented in
            if !presented {
                onClose()
            }
        }), onFinish: { r in
            isPresented = false
            onFinish?(r)
        })
    }
}
