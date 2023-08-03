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
    
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        cameraPermission.checkCameraPermission(completion: completion)
    }
    
    @available(iOS 15.0, *)
    func checkPermission(for type: WKMediaCaptureType, completion: @escaping (WKPermissionDecision) -> Void) {
        cameraPermission.checkPermission(for: type, completion: completion)
    }
    
}
