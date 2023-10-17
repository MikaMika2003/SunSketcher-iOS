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
    
    @Environment(\.isPresented) private var isPresented
    
    
    var body: some View {
        ZStack {
            
            VStack {
                Spacer()
                
                Button(action: {}, label: {
                    
                })
                
            }
            
        }
    }
}
