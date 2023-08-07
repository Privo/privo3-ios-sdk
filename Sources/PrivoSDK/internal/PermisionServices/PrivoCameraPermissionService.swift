import Foundation
import WebKit
import AVFoundation

protocol PrivoCameraPermissionServiceType {
    func checkCameraPermission(completion: @escaping (Bool) -> Void)
    func checkCameraPermission() async -> Bool
    @available(iOS 15.0, *)
    func checkPermission(for type: WKMediaCaptureType, completion: @escaping (WKPermissionDecision) -> Void)
    @available(iOS 15.0, *)
    func checkPermission(for type: WKMediaCaptureType) async -> WKPermissionDecision
}

class PrivoCameraPermissionService: PrivoCameraPermissionServiceType {
    
    //MARK: - Static properties
    
    public static var shared = PrivoCameraPermissionService()
    
    //MARK: - Internal properties
    
    let queue: DispatchQueue
    
    //MARK: - Private initialisers
    
    private init(queue: DispatchQueue = .main) {
        self.queue = queue
    }
    
    //MARK: - Internal functions
    
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        queue.async {
            let mediaType: AVMediaType = .video
            let currentPermission = AVCaptureDevice.authorizationStatus(for: mediaType)
            guard currentPermission == .notDetermined else {
                completion(currentPermission == .authorized); return
            }
            AVCaptureDevice.requestAccess(for: mediaType) { [weak self] result in
                self?.queue.async { completion(result) }
            }
        }
    }
    
    @MainActor
    func checkCameraPermission() async -> Bool {
        return await withCheckedContinuation { promise in
            checkCameraPermission { promise.resume(returning: $0) }
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
    
    @MainActor
    @available(iOS 15.0, *)
    func checkPermission(for type: WKMediaCaptureType) async -> WKPermissionDecision {
        return await withCheckedContinuation({ promise in
            checkPermission(for: type) { promise.resume(returning: $0)}
        })
    }
}
