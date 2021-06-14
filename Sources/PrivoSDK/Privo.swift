
public class Privo {
    private init () {}
    public static func initialize (settings: PrivoSettings) {
        PrivoInternal.initialize(settings: settings)
    }
    public static let auth = PrivoAuth();
}
