import Foundation
import AVFoundation

class PrivoCameraPermissionService {
    
    //MARK: - Static properties
    
    public static var shared = PrivoCameraPermissionService()
    
    //MARK: - Private properties
    
    let queue: DispatchQueue
    
    //MARK: - Private initialisers
    
    private init(queue: DispatchQueue = .main) {
        self.queue = queue
    }
    
    //MARK: - Internal functions
    
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        queue.async {
            let mediaType: AVMediaType = .video
            let currentPermission = AVCaptureDevice.authorizationStatus(for: mediaType) == .authorized
            if currentPermission {
                completion(currentPermission)
            } else {
                AVCaptureDevice.requestAccess(for: mediaType, completionHandler: completion)
            }
        }
    }
    
}
