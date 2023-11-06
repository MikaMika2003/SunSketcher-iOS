//
//  CameraService.swift
//  Sunsketcher
//
//  Created by ADMIN on 10/9/23.
//

import Foundation
import AVFoundation
import Photos

class CameraService {
    
    var session: AVCaptureSession?
    var delegate: AVCapturePhotoCaptureDelegate?
    
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    
    // for automatic camera function
    var photoTimer: Timer?
    var photoCount = 0
    var maxPhotoCount = 10
    
    // Specify the directory where photos will be saved
    /*let photoSaveDirectory: URL = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("CapturedPhotos")
    }()*/
    
    
    
    func start(delegate: AVCapturePhotoCaptureDelegate, completion: @escaping (Error?) -> ()) {
        self.delegate = delegate
        checkPermissions(completion: completion)
    }
    
    private func checkPermissions(completion: @escaping (Error?) -> ()) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {return}
                DispatchQueue.main.async {
                    self?.setUpCamera(completion: completion)
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera(completion: completion)
        @unknown default:
            break
        }
    }
    
    private func setUpCamera(completion: @escaping (Error?) -> ()) {
        let session = AVCaptureSession()
        
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning()
                self.session = session
                
                // Start the timer to capture photos every x seconds
                photoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
                
                
            } catch {
                completion(error)
            }
        }
        
    }
    
    @objc func timerFired() {
        capturePhoto()
        
        photoCount += 1
        
        // If we've reached the desired number of photos, stop the timer
        if photoCount >= maxPhotoCount {
            photoTimer?.invalidate()
        }
    }
    
    func capturePhoto(with settings: AVCapturePhotoSettings = AVCapturePhotoSettings()) {
        output.capturePhoto(with: settings, delegate: delegate!)
    }
    
    func savePhotoToLibrary(_ photo: AVCapturePhoto) {
        PHPhotoLibrary.shared().performChanges {
            // Create a request to add the photo to the user's photo library
            let request = PHAssetCreationRequest.forAsset()
            
            if let photoData = photo.fileDataRepresentation() {
                request.addResource(with: .photo, data: photoData, options: nil)
            }
        } completionHandler: { success, error in
            if success {
                print("Photo saved to the user's photo library")
            } else if let error = error {
                print("Error saving photo to the library: \(error.localizedDescription)")
            }
        }
    }
    
    func savePhotoToDocumentDirectory(_ photo: AVCapturePhoto) {
            // Specify the directory where photos will be saved (in your existing code)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let photoSaveDirectory = documentsDirectory.appendingPathComponent("CapturedPhotos")
            
            // Create the directory if it doesn't exist
            do {
                try FileManager.default.createDirectory(at: photoSaveDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory: \(error.localizedDescription)")
                return
            }
            
            // Generate a unique filename based on the current date and time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
            let fileName = "\(dateFormatter.string(from: Date())).jpg"
            
            // Save the photo to the document directory
            let photoURL = photoSaveDirectory.appendingPathComponent(fileName)
            
            if let photoData = photo.fileDataRepresentation() {
                do {
                    try photoData.write(to: photoURL)
                    print("Photo saved to: \(photoURL)")
                    
                    // Check time accuracy
                    // Record the current date and time
                    let creationDate = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let formattedCreationDate = dateFormatter.string(from: creationDate)
                    print("Creation Date: \(formattedCreationDate)")
                    
                } catch {
                    print("Error saving photo to file: \(error.localizedDescription)")
                }
            }
        }
    
    
    
    //To save to a directory
    /*func savePhoto(_ photo: AVCapturePhoto) {
            // Generate a unique file name for each photo (e.g., using a timestamp)
            let fileName = "photo_\(Date().timeIntervalSince1970).jpeg"
            let photoURL = photoSaveDirectory.appendingPathComponent(fileName)
            
            // Save the photo data to the specified file URL
            if let photoData = photo.fileDataRepresentation() {
                do {
                    try photoData.write(to: photoURL)
                    print("Photo saved to: \(photoURL)")
                } catch {
                    print("Error saving photo: \(error.localizedDescription)")
                }
            }
        }*/
    
}
