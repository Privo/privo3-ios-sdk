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
    }
    struct GPU: Decodable, Encodable {
    }
    let idForVendor: String
    let deviceInfo: DeviceInfo
    let browserInfo: BrowserInfo
    let gpu: GPU
    
    init () throws {
        var isMobile = true
        #if os(macOS)
            isMobile = false
        #endif
        self.deviceInfo = DeviceInfo(isMobile: isMobile,
                                     devModel: UIDevice.current.model,
                                     devVendor: "Apple",
                                     osName: UIDevice.current.systemName,
                                     osVersion: UIDevice.current.systemVersion,
                                     screenWidth: Int(UIScreen.main.bounds.width),
                                     screenHeight: Int(UIScreen.main.bounds.height),
                                     colorDepth: 32,
                                     pixelRatio: Double(UIScreen.main.scale))
        self.browserInfo = BrowserInfo(name: "WKWebView", version: "1")
        self.gpu = GPU()
        self.idForVendor = UIDevice.current.identifierForVendor!.uuidString
    }
}

struct DeviceFingerprintResponse: Decodable, Encodable {
    let id: String
    let exp: Int
}
