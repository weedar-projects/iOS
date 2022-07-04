//
//  CameraPermission.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 28.06.2022.
//

import SwiftUI
import AVFoundation


class CameraManager : ObservableObject {
    
    @Published var permissionGranted = true
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            DispatchQueue.main.async {
                self.permissionGranted = accessGranted
                print("accessGranted   \(accessGranted)")
            }
        })
    }
    
    
    func checkCameraAccess(showAlert: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            print("Denied, request permission from settings")
            showAlert()
        case .authorized:
            print("Authorized, proceed")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    print("Permission granted, proceed")
                } else {
                    print("Permission denied")
                    showAlert()
                }
            }
        }
    }
}
