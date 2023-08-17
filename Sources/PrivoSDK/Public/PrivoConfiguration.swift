import Foundation

public class PrivoConfiguration {
    
    //MARK: - Internal properties
    
    let type: EnviromentType
    let authBaseUrl: URL
    let authStartUrl: URL
    let verificationUrl: URL
    let helperUrl: URL
    let lgsRegistrationUrl: URL
    let ageGateBaseUrl: URL
    let ageGatePublicUrl: URL
    let ageVerificationBaseUrl: URL
    let ageVerificationPublicUrl: URL
    let tokenStorageKey: String
    let privoServiceKey: String
    
    //MARK: - Private initialisers
    
    private init (type: EnviromentType) {
        self.type = type
        self.privoServiceKey = "com.privo.sdk"
        switch type {
        case .Local:
            self.authBaseUrl = URL(string: "https://auth-dev.privo.com/api/v1.0")!
            self.authStartUrl = URL(string: "https://auth-dev.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=https%3A%2F%2Faccount-dev.privo.com%2Fauth%2F%23%2Fcongratulation")!
            self.verificationUrl = URL(string: "https://verification-dev.privo.com/vw")!
            self.helperUrl = URL(string: "https://helper-svc-dev.privo.com/rest/api/v1.0")!
            self.lgsRegistrationUrl = URL(string: "https://privohub-dev.privo.com/lgs")!
            self.ageGateBaseUrl = URL(string: "https://agegate-dev.privo.com/api/v1.0/age-gate")!
            self.ageGatePublicUrl = URL(string: "https://age-dev.privo.com/gate")!
            self.ageVerificationBaseUrl = URL(string: "https://ageverification-dev.privo.com/api/v1.0")!
            self.ageVerificationPublicUrl = URL(string: "https://age-dev.privo.com/verification")!
            self.tokenStorageKey = "privo-token-local"
        case .Dev:
            self.authBaseUrl = URL(string: "https://auth-dev.privo.com/api/v1.0")!
            self.authStartUrl = URL(string: "https://auth-dev.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=https%3A%2F%2Faccount-dev.privo.com%2Fauth%2F%23%2Fcongratulation")!
            self.verificationUrl = URL(string: "https://verification-dev.privo.com/vw")!
            self.helperUrl = URL(string: "https://helper-svc-dev.privo.com/rest/api/v1.0")!
            self.lgsRegistrationUrl = URL(string: "https://privohub-dev.privo.com/lgs")!
            self.ageGateBaseUrl = URL(string: "https://agegate-dev.privo.com/api/v1.0/age-gate")!
            self.ageGatePublicUrl = URL(string: "https://age-dev.privo.com/gate")!
            self.ageVerificationBaseUrl = URL(string: "https://ageverification-dev.privo.com/api/v1.0")!
            self.ageVerificationPublicUrl = URL(string: "https://age-dev.privo.com/verification")!
            self.tokenStorageKey = "privo-token-dev"
        case .Int:
            self.authBaseUrl = URL(string: "https://auth-int.privo.com/api/v1.0")!
            self.authStartUrl = URL(string: "https://auth-int.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=https%3A%2F%2Faccount-int.privo.com%2Fauth%2F%23%2Fcongratulation")!
            self.verificationUrl = URL(string: "https://verification-int.privo.com/vw")!
            self.helperUrl = URL(string: "https://helper-svc-int.privo.com/rest/api/v1.0")!
            self.lgsRegistrationUrl = URL(string: "https://privohub-int.privo.com/lgs")!
            self.ageGateBaseUrl = URL(string: "https://agegate-int.privo.com/api/v1.0/age-gate")!
            self.ageGatePublicUrl = URL(string: "https://age-int.privo.com/gate")!
            self.ageVerificationBaseUrl = URL(string: "https://ageverification-int.privo.com/api/v1.0")!
            self.ageVerificationPublicUrl = URL(string: "https://age-int.privo.com/verification")!
            self.tokenStorageKey = "privo-token-int"
        case .Test:
            self.authBaseUrl = URL(string: "https://auth-test.privo.com/api/v1.0")!
            self.authStartUrl = URL(string: "https://auth-test.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=https%3A%2F%2Faccount-test.privo.com%2Fauth%2F%23%2Fcongratulation")!
            self.verificationUrl = URL(string: "https://verification-test.privo.com/vw")!
            self.helperUrl = URL(string: "https://helper-svc-test.privo.com/rest/api/v1.0")!
            self.lgsRegistrationUrl = URL(string: "https://privohub-test.privo.com/lgs")!
            self.ageGateBaseUrl = URL(string: "https://agegate-test.privo.com/api/v1.0/age-gate")!
            self.ageGatePublicUrl = URL(string: "https://age-test.privo.com/gate")!
            self.ageVerificationBaseUrl = URL(string: "https://ageverification-test.privo.com/api/v1.0")!
            self.ageVerificationPublicUrl = URL(string: "https://age-test.privo.com/verification")!
            self.tokenStorageKey = "privo-token-test"
        case .Prod:
            self.authBaseUrl = URL(string: "https://auth.privo.com/api/v1.0")!
            self.authStartUrl = URL(string: "https://auth.privo.com/api/v1.0/privo/authorize?client_id=mobile&redirect_uri=https%3A%2F%2Faccount.privo.com%2Fauth%2F%23%2Fcongratulation")!
            self.verificationUrl = URL(string: "https://verification.privo.com/vw")!
            self.helperUrl = URL(string: "https://helper-svc.privo.com/rest/api/v1.0")!
            self.lgsRegistrationUrl = URL(string: "https://privohub.privo.com/lgs")!
            self.ageGateBaseUrl = URL(string: "https://agegate.privo.com/api/v1.0/age-gate")!
            self.ageGatePublicUrl = URL(string: "https://age.privo.com/gate")!
            self.ageVerificationBaseUrl = URL(string: "https://ageverification.privo.com/api/v1.0")!
            self.ageVerificationPublicUrl = URL(string: "https://age.privo.com/verification")!
            self.tokenStorageKey = "privo-token"
        }
    }
    
    //MARK: - Public initialisers
    
    public init(type: EnviromentType,
                authBaseUrl: URL? = nil,
                authStartUrl: URL? = nil,
                verificationUrl: URL? = nil,
                helperUrl: URL? = nil,
                lgsRegistrationUrl: URL? = nil,
                ageGateBaseUrl: URL? = nil,
                ageGatePublicUrl: URL? = nil,
                ageVerificationBaseUrl: URL? = nil,
                ageVerificationPublicUrl: URL? = nil,
                tokenStorageKey: String? = nil,
                privoServiceKey: String? = nil) {
        self.type = type
        let defaultValues = PrivoConfiguration(type: type)

        self.authBaseUrl = authBaseUrl ?? defaultValues.authBaseUrl
        self.authStartUrl = authStartUrl ?? defaultValues.authStartUrl
        self.verificationUrl = verificationUrl ?? defaultValues.verificationUrl
        self.helperUrl = helperUrl ?? defaultValues.helperUrl
        self.lgsRegistrationUrl = lgsRegistrationUrl ?? defaultValues.lgsRegistrationUrl
        self.ageGateBaseUrl = ageGateBaseUrl ?? defaultValues.ageGateBaseUrl
        self.ageGatePublicUrl = ageGatePublicUrl ?? defaultValues.ageGatePublicUrl
        self.ageVerificationBaseUrl = ageVerificationBaseUrl ?? defaultValues.ageVerificationBaseUrl
        self.ageVerificationPublicUrl = ageVerificationPublicUrl ?? defaultValues.ageVerificationPublicUrl
        self.tokenStorageKey = tokenStorageKey ?? defaultValues.tokenStorageKey
        self.privoServiceKey = tokenStorageKey ?? defaultValues.tokenStorageKey
    }
    
}
