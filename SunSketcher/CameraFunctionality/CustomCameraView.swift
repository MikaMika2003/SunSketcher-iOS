//
//  CustomCameraView.swift
//  Sunsketcher
//
//  Created by ADMIN on 10/10/23.
//

import SwiftUI


struct CustomCameraView: View {
    
    let cameraService = CameraService()
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    
    
    var body: some View {
        ZStack {
            CameraView(cameraService: cameraService) { result in
                switch result {
                case .success(let photo):
                    if let data = photo.fileDataRepresentation() {
                        
                        // Convert the captured photo to UIImage
                        if let image = UIImage(data: data) {
                            
                            // Save the photo with a custom name to the document directory
                            cameraService.saveImageToDocumentDirectory(image)
                            // Save photo to photo library in the "SunSketcher" album
                            cameraService.savePhotoToLibrary(photo)
                            capturedImage = image
                            //dismiss()
                        } else {
                            print("Error: Unable to convert photo to UIImage")
                        }
                        
                        
                        
                        
                        //capturedImage = UIImage(data: data)
                        
                        // Save photo to photo library
                        //cameraService.savePhotoToLibrary(photo)
                        //cameraService.savePhotoToDocumentDirectory(photo)
 
                        
                        
                        //dismiss()
                    } else {
                        print("Error: no image data found")
                    }
                    
                case .failure(let err):
                    print(err.localizedDescription)
                }
                
                
            }
        }
    }
}
