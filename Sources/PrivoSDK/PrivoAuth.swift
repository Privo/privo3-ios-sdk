import SwiftUI
import JWTDecode

/// SwiftUI button element that opens a modal window by clicking on it. User is prompted to Sign In inside this modal window. Depending on the integration settings, this button can be customized with branded PRIVO styles by default.
public struct PrivoAuthButton<Label> : View where Label : View {
    
    //MARK: - Internal properties
    
    @State var isPresented = false
    let label: Label
    var closeIcon: Image?
    let onFinish: ((String?) -> Void)?
    
    //MARK: - Private properties
    
    private let accessIdKey = "accessId"
    
    //MARK: - Public initialisers
   
    /// Constructor
    ///
    ///     PrivoAuthButton(label: {
    ///       Text("Sign In")
    ///     }, onFinish: { token in
    ///       self.token = token
    ///     }).padding()
    ///
    /// - Parameters:
    ///   - label: customizable Swift UI Label element for the button. It can contains text and any styling inside it.
    ///   - onFinish: optional completion callback that will provide token if Auth was successful. Otherwise it will provide nil.
    ///   - closeIcon: optional image for close icon in modal dialog. If nothing is specified, the default image will be used.
    public init(@ViewBuilder label: () -> Label,
                onFinish: ((String?) -> Void)? = nil,
                closeIcon: (() -> Image)? = nil) {
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

/// SwiftUI button element that opens a modal window by clicking on it. User is prompted to create an account inside this modal window. Depending on the integration settings, this button can be customized with branded PRIVO styles by default.
public struct PrivoRegisterButton<Label> : View where Label : View {
    
    //MARK: - Internal properties
    
    @Binding var isPresented: Bool
    let label: Label
    var closeIcon: Image?
    let onFinish: (() -> Void)?
    
    //MARK: - Public initialisers
    
    /// Constructor
    ///
    ///     PrivoRegisterButton(isPresented: $showRegistration, label: {
    ///       Text("Register")
    ///     }){
    ///       DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
    ///         showRegistration = false
    ///       }
    ///     }.padding()
    ///
    /// - Parameters:
    ///   - isPresented: binding state value that shows status of modal window presentation. Changed to true automatically when a user press button. Should be changed to false when you want to close the modal dialog.
    ///   - label: customizable SwiftUI Label element for the button. It can contains text and any styling inside it.
    ///   - onFinish: optional completion handler that will provide token if Auth was successful. Otherwise it will provide nil. You can change isPresented state value to false inside this callback. You also can change isPresented after some delay. In this case user will be able to see "Congratulation" page content inside modal dialog.
    ///   - closeIcon: optional image for close icon in modal dialog. If nothing is specified, the default image will be used.
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

public class PrivoAuth {
    
    public struct AuthDialog {
        fileprivate init() {}
        
        @MainActor
        public func hide() {
            UIApplication.shared.dismissTopView()
        }
    }
    
    public struct RegisterResponse: Codable {
        var resetPasswordLink: URL
        
        init(resetPasswordLink: URL) {
            self.resetPasswordLink = resetPasswordLink
        }
    }
    
    //MARK: - Private properties
    
    private let app: UIApplication
    private let userDefaults: UserDefaults
    private let api: Restable
    
    //MARK: - Public initialisers
    
    public init(app: UIApplication = .shared, userDefaults: UserDefaults = .standard) {
        self.app = app
        self.userDefaults = userDefaults
        self.api = Rest.shared
    }
    
    init(app: UIApplication = .shared, userDefaults: UserDefaults = .standard, api: Restable = Rest.shared) {
        self.app = app
        self.userDefaults = userDefaults
        self.api = api
    }
    
    //MARK: - Public functions
    
    /// Shows a modal window. User is prompted to Create an Account inside this modal window.
    /// NOTE: this dialog should be closed from completion callback. (*This can be done after a short delay. In this case, the user will be able to read content of the congratulations page.*)
    /// - Parameter completion: closure to execute.
    public func showRegister(_ completion: ((AuthDialog) -> Void)?) {
        Task.init(priority: .userInitiated) { @MainActor in
            let authDialog = AuthDialog()
            app.showView(false) {
                PrivoRegisterStateView(onClose: {
                    authDialog.hide()
                }) {
                    completion?(authDialog)
                }
            }
        }
    }
    
    /// Shows a modal window. User is prompted to Sign In inside this modal window. It returns a new user token as a result.
    /// - Parameter completion: closure to execute.
    public func showAuth(_ completion: ((String?) -> Void)?) {
        Task.init(priority: .userInitiated) { @MainActor in
            let authDialog = AuthDialog()
            app.showView(false) {
                PrivoAuthStateView(onClose: {
                    authDialog.hide()
                }, onFinish: { r in
                    authDialog.hide()
                    completion?(r)
                })
            }
        }
    }
    
    /// - Returns: a previously issued token, if it have not expired. Can return nil if token wasn't issued or expired
    public func getToken() -> String? {
        if let token = userDefaults.string(forKey: PrivoInternal.configuration.tokenStorageKey) {
            if let jwt = try? decode(jwt: token) {
                if let exp = jwt.expiresAt {
                    if exp > Date() {
                        return token
                    }
                } else {
                    return token
                }
            }
        }
        logout()
        return nil
    }
    
    /// Renew token. Return token and it's status.
    ///
    ///     Privo.auth.renewToken() { tokenStatus in
    ///       let token: String? = tokenStatus?.token
    ///       let isRenewed: Bool? = tokenStatus?.isRenewed
    ///     }
    ///
    /// - Parameter completionHandler: closure to execute.
    public func renewToken(completionHandler: @escaping (TokenStatus?) -> Void) {
        Task.init(priority: .userInitiated) {
            guard let oldToken = getToken() else {
                completionHandler(nil)
                return
            }
            guard let sessionId = await api.getAuthSessionId() else {
                completionHandler(nil)
                return
            }
            guard let newToken = await api.renewToken(oldToken: oldToken, sessionId: sessionId) else {
                completionHandler(.init(token: oldToken, isRenewed: false))
                return
            }
            userDefaults.set(newToken, forKey: PrivoInternal.configuration.tokenStorageKey)
            completionHandler(.init(token: newToken, isRenewed: true))
        }
    }
    
    /// Logout and clean previously issued token.
    public func logout() {
        userDefaults.removeObject(forKey: PrivoInternal.configuration.tokenStorageKey)
    }
    
    @discardableResult
    public func register(child: ChildData, parent: ParentData) async throws /*(PrivoError)*/ -> RegisterResponse {
        let gwTokenResponse = try await api.getGWToken()
        let gwToken = gwTokenResponse.accessToken
        
        let parentChildPair = ParentChildPair(
            roleIdentifier: parent.roleIdentifier,
            email: parent.email,
            minorRegistrations: [
                try .init(child: child)
            ])
        let response = try await api.registerParentAndChild(parentChildPair, gwToken)
        
        let childSid = try await api.getUserIdentifier(.userName(child.username), gwToken).sid
        
        // look through all childs for parent account and find which child update password link we need
        
        guard var resetPasswordLink = response.to.connectedProfiles.first(where: { $0.serviceId == childSid })?.updatePasswordLink else {
            throw PrivoError.incorrectAdminConsoleConfiguration(
                AdminConsoleConfigurationError.updatePasswordLinkNotFound
            )
        }
        
        let serviceIdentifier = PrivoInternal.settings.serviceIdentifier
        if let serviceInfo = await api.getServiceInfo(serviceIdentifier: serviceIdentifier),
           let siteId = serviceInfo.p2siteId
        {
            resetPasswordLink = resetPasswordLink.withQueryParam(replace: true, name: "siteId", value: String(siteId))
        }
        
        return .init(resetPasswordLink: resetPasswordLink)
    }
    
    @MainActor
    public func showUpdatePassword(registerResponse: RegisterResponse) async throws /*(PrivoError)*/ {
        let authDialog = AuthDialog()
        return try await withCheckedThrowingContinuation { promise in
            Task.init(priority: .userInitiated) { @MainActor in
                app.showView(presentationStyle: .overFullScreen, true) {
                    UpdatePasswordView(.init(url: registerResponse.resetPasswordLink,
                        onClose: {
                            Task { @MainActor in
                                authDialog.hide()
                                promise.resume(throwing: PrivoError.cancelled)
                            }
                        },
                       onFinish: {
                            Task { @MainActor in
                                authDialog.hide()
                                promise.resume(returning: ())
                            }
                        }))
                }
            }
        }
    }
    
    public func consentResend(requester: AccountIdentifier, approver: AccountIdentifier, approverEmail: String) async throws /* (PrivoError) */ {
        
        let gwTokenResponse = try await api.getGWToken()
        let gwToken = gwTokenResponse.accessToken
        
        async let requesterSid = api.getUserIdentifier(requester, gwToken).sid
        async let approverSid = api.getUserIdentifier(approver, gwToken).sid
                
        try await api.consentResend(requesterSid: requesterSid, approverSid: approverSid, email: approverEmail, gwToken)
    }
    
    public func userinfo(_ accountIdentifier: AccountIdentifier) async throws /* (PrivoError) */ -> UserInfo {
        let gwToken = try await api.getGWToken().accessToken
        let sid = try await api.getUserIdentifier(accountIdentifier, gwToken).sid
        
        return try await api.getUserInfo(sid: sid, gwToken).public
    }
    
    public func userinfo(token authcode: String) async throws /* (PrivoError) */ -> UserInfo {
        let gwToken = try await api.getGWToken(authcode).accessToken
        return try await api.getUserInfo(sid: nil, gwToken).public
    }
}
