import SwiftUI

struct UpdatePasswordView: View {
    
    let url: URL
    let onClose: (() -> Void)
    let onFinish: (() -> Void)?
    
    @State
    private var isPresented: Bool = true
    
    @State
    private var isPresentedAnimation: Bool = false

    @State
    private var config: WebviewConfig

    private var closeIcon: Image?
    private let backgroundColor: Color = .white
    
    public init(url url_: URL,
                onClose: @escaping () -> Void,
                onFinish: (() -> Void)? = nil) {
        // It's even better to add &mode=SIMPLE to the URL to hide the potential header and footer.
        self.url = url_.withQueryParam(name: "mode", value: "SIMPLE")
        self.onFinish = onFinish
        self.onClose = onClose
        self._config = State(initialValue: WebviewConfig(url: url,
            closeIcon: nil,
            showCloseIcon: false,
            scriptUrlTrigger: "about:blank",
            script: "document.querySelector(\"[ng-show='step == steps.COMPLETE']\").classList.contains(\"ng-hide\")",
            onFinish: { _ in onFinish?() },
            onClose: onClose
        ))
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(isPresentedAnimation ? 0.4 : 0)
                .allowsHitTesting(isPresentedAnimation)
                .transition(.opacity)
                .animation(.easeOut(duration: 0.3), value: isPresentedAnimation)
            
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(backgroundColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 26) // Sometimes, the background color may not be transparent, and applying a white background may not be visible. In this case, the header color will not match the background color. Let's make the header height moderate and not too narrow, so that in this case, the overall appearance of the pop-up widget does not look bad.
                        .cornerRadiusTop(8)
                    
                    ModalWebView(isPresented: $isPresented, config: config)
                        .background(backgroundColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 500)
                }
            }.edgesIgnoringSafeArea(.bottom)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    isPresentedAnimation = isPresented
                }
            }
            //since iOS14 use onChange (for isPresented variable) to updated isPresentedAnimation back
        }
    }
}
