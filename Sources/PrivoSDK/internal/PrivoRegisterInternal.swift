import SwiftUI

struct PrivoRegisterView: View {
    
    //MARK: - Internal properties
    
    @Binding
    var isPresented: Bool
    @State
    var config: WebviewConfig?
    @State
    var inProgress: Bool = true
    
    var closeIcon: Image?
    let onFinish: (() -> Void)?
    
    //MARK: - Private properties
    
    private let siteIdKey = "siteId"
    private let api: Restable
    
    //MARK: - Public initialisers
    
    public init(isPresented: Binding<Bool>,
                onFinish: (() -> Void)? = nil,
                closeIcon: Image? = nil,
                api: Restable = Rest.shared) {
        self.closeIcon = closeIcon
        self._isPresented = isPresented
        self.onFinish = onFinish
        self.api = api
    }
    
    //MARK: - Body builder
    
    public var body: some View {
        LoadingView(isShowing: $inProgress) {
            VStack {
                if config != nil {
                    ModalWebView(isPresented: self.$isPresented, config: config!)
                }
            }
        }.onAppear {
            showView()
        }
    }
    
    //MARK: - Internal functions
    
    func showView() {
        let serviceIdentifier = PrivoInternal.settings.serviceIdentifier
        api.getServiceInfo(serviceIdentifier: serviceIdentifier) { serviceInfo in
            inProgress = false
            guard let siteId = serviceInfo?.p2siteId else { return }
            let url = PrivoInternal.configuration.lgsRegistrationUrl.withQueryParam(name: siteIdKey, value: String(siteId))
            config = .init(url: url,
                           closeIcon: closeIcon,
                           finishCriteria: "step=complete",
                           onFinish: { _ in onFinish?() })
        }
    }
    
}

struct PrivoRegisterStateView : View {
    
    //MARK: - Internal properties
    
    @State var isPresented: Bool = true
    let onClose: (() -> Void)
    let onFinish: (() -> Void)?
    
    //MARK: - Body builder
    
    public var body: some View {
        PrivoRegisterView(isPresented: $isPresented.onChange({ presented in
            if !presented {
                onClose()
            }
        }), onFinish: onFinish)
    }
    
}
