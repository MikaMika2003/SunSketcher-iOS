//
//  ContentView.swift
//  Sunsketcher
//
//  Created by ADMIN on 8/25/23.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                VStack{
                    
                    Text("Latitude, Longitude:\n\(locationManager.location?.coordinate.latitude ?? 0.0),\(locationManager.location?.coordinate.longitude ?? 0.0)")
                    Text("Altitude:\n\(locationManager.location?.altitude ?? 0.0) m").padding()
                    //Text("Altitude: \n%.1f m", locationManager.location?.altitude ?? 0.0)
                    //Text("Timestamp:\n\(Date())")
                    
            
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
            
            
        }
        
        
    }
}

struct CameraUI2: View {
    
    @State private var capturedImage: UIImage? = nil
    @State private var isCustomCameraViewPresented = false
    
    
    var body: some View {
        
        CustomCameraView(capturedImage: $capturedImage)
        
        /*ZStack {
            if capturedImage != nil {
                Image(uiImage: capturedImage!)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                Color(UIColor.systemBackground)
            }
            
            VStack {
                Spacer()
                Button(action: {
                    isCustomCameraViewPresented.toggle()
                }, label: {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                })
                .padding(.bottom)
                .sheet(isPresented: $isCustomCameraViewPresented, content: {
                    CustomCameraView(capturedImage: $capturedImage)
                })
            }
        }*/
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() // Location doesn't show in Live Preview - use Simulator
            .environmentObject(LocationManager())
    }
}
