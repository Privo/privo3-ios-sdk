
public class Privo {
    public static let shared = Privo()
    static private var _configuration: Configuration?
    static private var _settings: PrivoSettings?
    private init () {}
    public static func initialize (settings: PrivoSettings) {
        self._settings = settings
        self._configuration = Configuration(type: settings.envType)
    }
    var configuration: Configuration {
        get {
            guard let configuration = Privo._configuration else {
                preconditionFailure("Privo SDK is not initialized, call Privo.initialize first")
            }
            return configuration
        }
    }
    var settings: PrivoSettings {
        get {
            guard let settings = Privo._settings else {
                preconditionFailure("Privo SDK is not initialized, call Privo.initialize first")
            }
            return settings
        }
    }
    public let auth = PrivoAuth();
    internal let rest = Rest();

}
