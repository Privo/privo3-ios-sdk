//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 14.07.2021.
//

import UIKit


struct DeviceFingerprint: Decodable, Encodable {
    struct DeviceInfo: Decodable, Encodable {
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
    struct BrowserInfo: Decodable, Encodable {
        let name: String
        let version: String
        let plugins: [String]
    }
    struct GPU: Decodable, Encodable {
    }
    struct Fonts: Decodable, Encodable {
        let fonts: [String]
    }
    let idForVendor: String
    let devInfo: DeviceInfo
    let browserInfo: BrowserInfo
    let gpu: GPU
    let fonts: Fonts
    
    init () throws {
        var isMobile = true
        #if os(macOS)
            isMobile = false
        #endif
        self.devInfo = DeviceInfo(isMobile: isMobile,
                                     devModel: UIDevice.current.model,
                                     devVendor: "Apple",
                                     osName: UIDevice.current.systemName,
                                     osVersion: UIDevice.current.systemVersion,
                                     screenWidth: Int(UIScreen.main.bounds.width),
                                     screenHeight: Int(UIScreen.main.bounds.height),
                                     colorDepth: 32,
                                     pixelRatio: Double(UIScreen.main.scale))
        self.browserInfo = BrowserInfo(name: "WKWebView", version: "1", plugins: [])
        self.gpu = GPU()
        self.fonts = Fonts(fonts: [])
        self.idForVendor = try! DeviceIdentifier().identifier
    }
}

struct DeviceFingerprintResponse: Decodable, Encodable {
    let id: String
    let exp: Int
}
