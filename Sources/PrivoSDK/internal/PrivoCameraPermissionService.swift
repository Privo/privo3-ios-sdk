import Foundation
import WebKit
import AVFoundation

protocol PrivoCameraPermissionServiceType {
    func checkCameraPermission(completion: @escaping (Bool) -> Void)
    @available(iOS 15.0, *)
    func checkPermission(for type: WKMediaCaptureType, completion: @escaping (WKPermissionDecision) -> Void)
}

class PrivoCameraPermissionService: PrivoCameraPermissionServiceType {
    
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
                AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { [weak self] result in
                    guard let self = self else { return }
                    self.queue.async { completion(result) }
                })
            }
        }
    }
    
    @available(iOS 15.0, *)
    func checkPermission(for type: WKMediaCaptureType, completion: @escaping (WKPermissionDecision) -> Void) {
        guard type == .camera else { completion(.prompt); return }
        checkCameraPermission { [weak self] result in
            guard let self = self else { return }
            let decision: WKPermissionDecision = result ? .grant : .deny
            queue.async { completion(decision) }
        }
    }
    
}
