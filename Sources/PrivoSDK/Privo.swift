
public class Privo {
    public static let shared = Privo()
    private init () {}
    public static func initialize (settings: PrivoSettings) {
        PrivoInternal.initialize(settings: settings)
    }
    public let auth = PrivoAuth();
}
