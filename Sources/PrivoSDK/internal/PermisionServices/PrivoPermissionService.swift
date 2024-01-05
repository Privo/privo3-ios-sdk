//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
import AVFoundation
import WebKit

protocol PrivoPermissionServiceType: PrivoCameraPermissionServiceType {
    
}

class PrivoPermissionService: PrivoPermissionServiceType {
    
    //MARK: - Static properties
    
    static var shared = PrivoPermissionService()
    
    //MARK: - Private properties
    
    private let cameraPermission: PrivoCameraPermissionServiceType
    
    //MARK: - Private initialiser
    
    private init(cameraPermission: PrivoCameraPermissionServiceType = PrivoCameraPermissionService.shared) {
        self.cameraPermission = cameraPermission
    }
    
}


//MARK: - Implementation PrivoCameraPermissionServiceType

extension PrivoPermissionService: PrivoCameraPermissionServiceType {
    
    func checkCameraPermission() async -> Bool {
        await cameraPermission.checkCameraPermission()
    }
    
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        cameraPermission.checkCameraPermission(completion: completion)
    }
    
    @available(iOS 15.0, *)
    func checkPermission(for type: WKMediaCaptureType) async -> WKPermissionDecision {
        await cameraPermission.checkPermission(for: type)
    }
    
    @available(iOS 15.0, *)
    func checkPermission(for type: WKMediaCaptureType, completion: @escaping (WKPermissionDecision) -> Void) {
        cameraPermission.checkPermission(for: type, completion: completion)
    }
    
}
