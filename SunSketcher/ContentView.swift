//
//  ContentView.swift
//  Sunsketcher
//
//  Created by ADMIN on 8/25/23.
//

import SwiftUI
import AVFoundation
import Photos
import CoreLocation


struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var isPermissionRequested = false
    private var main = SunSketcherApp()
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                VStack{
                    
                    Text("Latitude, Longitude:\n\(locationManager.location?.coordinate.latitude ?? 0.0),\(locationManager.location?.coordinate.longitude ?? 0.0)")
                    Text("Altitude:\n\(locationManager.location?.altitude ?? 0.0) m").padding()
                    
                    Button("Get Location") {
                        main.getLocation(locationMan: locationManager)
                    }
                    
                    
                    NavigationLink(destination: CameraUI2(), label: {
                        Text("Camera Function")
                            .bold()
                            .frame(width: 280, height: 50)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                        
                    })
                }
            }
            .onAppear {
                if !isPermissionRequested {
                    requestPermissions()
                }
            }
        }
    }
    
    private func requestPermissions() {
        // Request location permission
        locationManager.requestLocationPermission()
        
        // Request camera permission
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                // Camera permission granted
                print("Camera permission granted")
            } else {
                // Camera permission denied
                print("Camera permission denied")
            }
        }
        
        // Request photo library permission
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                // Photo library permission granted
                print("Photo library permission granted")
            case .denied, .restricted:
                // Photo library permission denied
                print("Photo library permission denied")
            case .notDetermined:
                // The user hasn't made a choice yet
                print("Photo library permission not determined")
            default:
                break
            }
        }
        
        isPermissionRequested = true
    }
}

struct CameraUI2: View {
    
    @State private var capturedImage: UIImage? = nil
    @State private var isCustomCameraViewPresented = false
    
    
    var body: some View {
        
        CustomCameraView(capturedImage: $capturedImage)
            .navigationBarBackButtonHidden(true)
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() // Location doesn't show in Live Preview - use Simulator
            .environmentObject(LocationManager())
    }
}
