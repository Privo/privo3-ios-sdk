
public class Privo {
    
    //MARK: - Public properties
    
    public static let auth = PrivoAuth()
    public static let ageGate = PrivoAgeGate.init()
    public static let ageVerification = PrivoAgeVerification()
    public static let verification = PrivoVerification()
    
    public static var getSettings: PrivoSettings {
        return PrivoInternal.settings
    }
    
    //MARK: - Public functions
    public static func initialize(settings: PrivoSettings) {
        PrivoInternal.initialize(settings: settings)
    }
    public static func overrideConfiguration (configuration: PrivoConfiguration) {
        PrivoInternal.overrideConfiguration(configuration: configuration)
    }
    
    
    //MARK: - Private initialisers
    
    private init () {}
    

}
