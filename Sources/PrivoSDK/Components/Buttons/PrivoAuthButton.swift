import SwiftUI
import JWTDecode

public struct PrivoAuthButton<Label>: View where Label:View {
    
    //MARK: - Internal properties
    
    @State var isPresented = false
    let label: Label
    var closeIcon: Image?
    let onFinish: ((String?) -> Void)?
    
    //MARK: - Private properties
    
    private let accessIdKey = "accessId"
    
    //MARK: - Public initialisers
    
    public init(@ViewBuilder label: () -> Label, onFinish: ((String?) -> Void)? = nil, closeIcon: (() -> Image)? = nil) {
        self.label = label()
        self.closeIcon = closeIcon?()
        self.onFinish = onFinish
    }
    
    //MARK: - Body builder
    
    public var body: some View {
        return Button {
            isPresented = true
        } label: {
            label
        }.sheet(isPresented: $isPresented) {
            PrivoAuthView(isPresented: $isPresented, onFinish: { r in
                isPresented = false
                onFinish?(r)
            }, closeIcon: closeIcon)
        }
    }
}
