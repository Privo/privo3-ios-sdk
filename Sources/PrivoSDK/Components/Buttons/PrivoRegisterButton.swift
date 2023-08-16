import SwiftUI

public struct PrivoRegisterButton<Label>:View where Label:View {
    
    //MARK: - Internal properties
    
    @Binding var isPresented: Bool
    let label: Label
    var closeIcon: Image?
    let onFinish: (() -> Void)?
    
    //MARK: - Public initialisers
    
    public init(isPresented: Binding<Bool>,
                @ViewBuilder label: () -> Label,
                onFinish: (() -> Void)? = nil,
                closeIcon: (() -> Image)? = nil ) {
        self.label = label()
        self.closeIcon = closeIcon?()
        self._isPresented = isPresented
        self.onFinish = onFinish
    }
    
    //MARK: - Body builder
    
    public var body: some View {
        return Button {
            isPresented = true
        } label: {
            label
        }.sheet(isPresented: $isPresented) {
            PrivoRegisterView(isPresented: $isPresented, onFinish: onFinish, closeIcon: closeIcon)
        }
    }
    
}
