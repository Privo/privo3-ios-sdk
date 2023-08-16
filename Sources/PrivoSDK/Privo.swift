
public class Privo {
    
    public static func initialize(settings: PrivoSettings) {
        PrivoInternal.initialize(settings: settings)
    }
    
    public static func overrideConfiguration(configuration: PrivoConfiguration) {
        PrivoInternal.overrideConfiguration(configuration: configuration)
    }
    
    public static func getSettings() -> PrivoSettings {
        return PrivoInternal.settings
    }
    
    public static let auth = PrivoAuth()
    public static let ageGate = PrivoAgeGate()
    public static let ageVerification = PrivoAgeVerification()
    public static let verification = PrivoVerification()

    private init () {}
    
}
