import Foundation

public class Privo {
    
    //MARK: - Public properties
    
    public static let auth = PrivoAuthManager()
    public static let ageGate = PrivoAgeGateManager()
    public static let ageVerification = PrivoAgeVerificationManager()
    public static let verification = PrivoVerificationManager()
    
    public static var getSettings: PrivoSettings {
        return PrivoService.settings
    }

    //MARK: - Private initialisers
    
    private init() {}
    
    //MARK: - Public functions
    
    public static func initialize(settings: PrivoSettings) {
        PrivoService.initialize(settings: settings)
    }
    
    public static func overrideConfiguration(configuration: PrivoConfiguration) {
        PrivoService.overrideConfiguration(configuration: configuration)
    }
    
}
