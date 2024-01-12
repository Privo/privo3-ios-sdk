public struct PrivoSettings: Encodable {
    
    /// Required partner identifier in PRIVO system. Must be received from the PRIVO.
    public let serviceIdentifier: String
    
    /// Type on enviroment on what are you going to use PRIVO.
    ///
    ///  Can be .Int or .Prod:
    /// - for integration purpose partners should use EnviromentType.Int
    /// - for production apps partners should use Enviroment.Prod
    public let envType: EnviromentType
    
    /// Optional parameter that is used in the identity verification module. *Can be nil.*
    public let apiKey: String?
    
    public init(serviceIdentifier: String, envType: EnviromentType, apiKey: String? = nil) {
        self.serviceIdentifier = serviceIdentifier
        self.envType = envType
        self.apiKey = apiKey
    }
}

// conforms Decodable for test purposes
extension PrivoSettings: Decodable {}
