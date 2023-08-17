import UIKit

struct DeviceInfo: Codable {
    let isMobile: Bool
    let devModel: String
    let devVendor: String
    let osName: String
    let osVersion: String
    let screenWidth: Int
    let screenHeight: Int
    let colorDepth: Int
    let pixelRatio: Double
}

struct BrowserInfo: Codable {
    let name: String
    let version: String
    let plugins: [String]
}

struct GPU: Codable { }

struct Fonts: Codable {
    let fonts: [String]
}

struct DeviceFingerprint: Codable {
    
    //MARK: - Internal properties
    
    let idForVendor: String
    let devInfo: DeviceInfo
    let browserInfo: BrowserInfo
    let gpu: GPU
    let fonts: Fonts
    
    //MARK: - Internal initialisers
    
    init () {
        var isMobile = true
        #if os(macOS)
            isMobile = false
        #endif
        self.devInfo = .init(isMobile: isMobile,
                             devModel: UIDevice.current.model,
                             devVendor: "Apple",
                             osName: UIDevice.current.systemName,
                             osVersion: UIDevice.current.systemVersion,
                             screenWidth: Int(UIScreen.main.bounds.width),
                             screenHeight: Int(UIScreen.main.bounds.height),
                             colorDepth: 32,
                             pixelRatio: Double(UIScreen.main.scale))
        self.browserInfo = .init(name: "WKWebView", version: "1", plugins: [])
        self.gpu = GPU()
        self.fonts = .init(fonts: [])
        self.idForVendor = DeviceIdentifier().identifier
    }
    
}
