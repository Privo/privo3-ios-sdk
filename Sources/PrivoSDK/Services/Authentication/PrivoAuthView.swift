import SwiftUI

struct PrivoAuthView: View {
    
    //MARK: - Internal properties
    
    @Binding var isPresented: Bool
    var closeIcon: Image?
    let onFinish: ((String?) -> Void)?
    
    //MARK: - Private properties
    
    private let accessIdKey = "access_id"
    private let api: Rest = .shared
    private let userDefaults: UserDefaults = .standard
    
    //MARK: - Public initialisers
    
    public init(isPresented: Binding<Bool>, onFinish: ((String?) -> Void)? = nil, closeIcon: Image? = nil) {
        self._isPresented = isPresented
        self.closeIcon = closeIcon
        self.onFinish = onFinish
    }
    
    //MARK: - Body builder
    
    public var body: some View {
        ModalWebView(isPresented: $isPresented, config: getConfig())
    }
    
    //MARK: - Internal functions
    
    func getConfig() -> WebviewConfig {
        let serviceIdentifier = PrivoService.settings.serviceIdentifier;
        var urlComponents = URLComponents(url: PrivoService.configuration.authStartUrl, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems?.append(URLQueryItem(name: "service_identifier", value: serviceIdentifier))
        let url = urlComponents?.url ?? PrivoService.configuration.authStartUrl
        return .init(url: url,
                     closeIcon: closeIcon,
                     finishCriteria: accessIdKey,
                     onFinish: { url in
            if let items = URLComponents(string: url)?.queryItems,
                let accessId = items.first(where: {$0.name == accessIdKey})?.value {
                api.getValueFromTMPStorage(key: accessId) { resp in
                    let token = resp?.data
                    if (token != nil) {
                        userDefaults.set(token, forKey: PrivoService.configuration.tokenStorageKey)
                    }
                    onFinish?(token)
                }
            } else {
                onFinish?(nil)
            }
        })
    }
   
}
