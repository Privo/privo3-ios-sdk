import SwiftUI

struct PrivoRegisterView: View {
    
    //MARK: - Internal properties
    
    @Binding var isPresented: Bool
    @State var config: WebviewConfig?
    @State var inProgress: Bool = true
    var closeIcon: Image?
    let onFinish: (() -> Void)?
    
    //MARK: - Private properties
    
    private let siteIdKey = "siteId"
    private let api: Rest = .shared
    
    //MARK: - Public initialiasers
    
    public init(isPresented: Binding<Bool>, onFinish: (() -> Void)? = nil, closeIcon: Image? = nil ) {
        self.closeIcon = closeIcon
        self._isPresented = isPresented
        self.onFinish = onFinish
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
        let serviceIdentifier = PrivoService.settings.serviceIdentifier
        api.getServiceInfo(serviceIdentifier: serviceIdentifier) { serviceInfo in
            inProgress = false
            if let siteId = serviceInfo?.p2siteId {
                let url = PrivoService.configuration.lgsRegistrationUrl.withQueryParam(name: siteIdKey, value: String(siteId))!
                config = WebviewConfig(
                    url: url,
                    closeIcon: closeIcon,
                    finishCriteria: "step=complete",
                    onFinish: { _ in onFinish?() }
                )
            }
        }
    }
   
}
