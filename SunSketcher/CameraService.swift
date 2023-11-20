//
//  CameraService.swift
//  Sunsketcher
//
//  Created by ADMIN on 10/9/23.
//

import Foundation
import AVFoundation
import Photos
import UIKit


class CameraService {
    
    var session: AVCaptureSession?
    var delegate: AVCapturePhotoCaptureDelegate?
    
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    
    // for automatic camera function
    var photoTimer: Timer?
    var photoCount = 0
    var maxPhotoCount = 41
    
    
    
    
    func start(delegate: AVCapturePhotoCaptureDelegate, completion: @escaping (Error?) -> ()) {
        self.delegate = delegate
        checkPermissions(completion: completion)
        
        // Schedule a timer to check and start capturing photos at the specified time
        scheduleTimerForPhotoCapture()
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
                // timeInterval determines how many seconds until the next photo will be taken
                //photoTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
                
                
            } catch {
                completion(error)
            }
        }
        
    }
    
    private func scheduleTimerForPhotoCapture() {
        // Schedule a timer to check and start capturing photos at the specified time
        let timer = Timer(fire: Date(), interval: 60, repeats: true) { [weak self] _ in
            // Check if it's time to start capturing photos (13th of November at 11:50 AM)
            if self?.shouldStartCapturingPhotos() == true {
                // Start capturing photos
                self?.photoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self!, selector: #selector(self!.timerFired), userInfo: nil, repeats: true)
            }
        }

        // Schedule the timer on the main run loop
        RunLoop.main.add(timer, forMode: .common)
    }

    
    func shouldStartCapturingPhotos() -> Bool {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Check if it's the specified time
     
        return calendar.component(.hour, from: currentDate) == 21
        && calendar.component(.minute, from: currentDate) == 00
        && calendar.component(.day, from: currentDate) == 23
        && calendar.component(.month, from: currentDate) == 11
    }

        
    @objc func timerFired() {
        
        //***** TWEAKED CODE TO RUN DR. ARBUCKLES TEST ******//
        if photoCount<20{
            //capture a photo every 0.l5 seconds for the first 20 photos
            capturePhoto()
        }
        
        else if photoCount == 20{
            //pause for 2.5 minutes after the first 20 photos are taken
            photoTimer?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 150){
                self.photoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
            }
        } else if photoCount == 21{
            //capture one photo after pausing for 2.5 minutes
            
            photoTimer?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 150){
                self.photoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
                
            }
            capturePhoto()
        } else if photoCount > 21 && photoCount <= 41 {
            capturePhoto()
        } else{
            photoTimer?.invalidate()
        }
        photoCount += 1

    }
    
    func capturePhoto(with settings: AVCapturePhotoSettings = AVCapturePhotoSettings()) {
        output.capturePhoto(with: settings, delegate: delegate!)
    }
    
    func createSunSketcherAlbumIfNeeded(completion: @escaping (PHAssetCollection?) -> Void) {
        // Check if the "SunSketcher" album exists, and if not, create it.
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "SunSketcher")
        
        if let existingAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject {
            // The album already exists.
            completion(existingAlbum)
        } else {
            // Create a new album with the name "SunSketcher."
            PHPhotoLibrary.shared().performChanges {
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "SunSketcher")
            } completionHandler: { success, error in
                if success {
                    // Get the newly created album and return it.
                    if let newAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject {
                        completion(newAlbum)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func savePhotoToLibrary(_ photo: AVCapturePhoto) {
        createSunSketcherAlbumIfNeeded { album in
            if let album = album {
                if let photoData = photo.fileDataRepresentation(), let image = UIImage(data: photoData) {
                    // Save the image with a custom file name to the document directory
                    self.saveImageToDocumentDirectory(image)
                    
                    PHPhotoLibrary.shared().performChanges {
                        let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                        // Set a custom file name for the photo in the album, e.g., based on the current timestamp.
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
                        let fileName = "SunSketcher_\(dateFormatter.string(from: Date())).jpg"
                        request.creationDate = Date()
                        request.location = CLLocation()
                        // Add the photo to the "SunSketcher" album.
                        if let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) {
                            albumChangeRequest.addAssets([request.placeholderForCreatedAsset!] as NSFastEnumeration)
                        }
                    } completionHandler: { success, error in
                        if success {
                            print("Photo saved to the 'SunSketcher' album")
                        } else if let error = error {
                            print("Error saving photo to the library: \(error.localizedDescription)")
                        }
                    }
                } else {
                    print("Error: Unable to create UIImage from photo data")
                }
            } else {
                print("Error creating 'SunSketcher' album")
            }
        }
    }


    
    // Add a method to save a UIImage to the document directory
    func saveImageToDocumentDirectory(_ image: UIImage) {
        // Specify the directory where images will be saved
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageSaveDirectory = documentsDirectory.appendingPathComponent("CapturedImages")

        // Create the directory if it doesn't exist
        do {
            try FileManager.default.createDirectory(at: imageSaveDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error.localizedDescription)")
            return
        }

        // Generate a unique filename based on the current date and time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let fileName = "\(dateFormatter.string(from: Date())).jpg"

        // Save the image to the document directory with the custom name
        let imageURL = imageSaveDirectory.appendingPathComponent(fileName)

        if let imageData = image.jpegData(compressionQuality: 1.0) {
            do {
                try imageData.write(to: imageURL)
                print("Image saved to: \(imageURL)")

                // Check time accuracy
                // Record the current date and time
                let creationDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let formattedCreationDate = dateFormatter.string(from: creationDate)
                print("Creation Date: \(formattedCreationDate)")
            } catch {
                print("Error saving image to file: \(error.localizedDescription)")
            }
        }
    }
    
}

