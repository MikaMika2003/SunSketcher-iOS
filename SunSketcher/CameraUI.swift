//
//  CameraUI.swift
//  Sunsketcher
//
//  Created by ADMIN on 9/20/23.
//

import SwiftUI
import AVFoundation

struct CameraUI: View {
    
    @State private var capturedImage: UIImage? = nil
    @State private var isCustomCameraViewPresented = false
    
    
    var body: some View {
        
        //CameraView()
        
        ZStack {
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
        }
        
    }
}

struct CameraUI_Previews: PreviewProvider {
    static var previews: some View {
        CameraUI()
    }
}










/*struct CameraView: View {
    
    @StateObject var camera = CameraModel()
    var body: some View {
        
        ZStack {
            
            //Camera preview
            CameraPreview(camera: camera)
            //Color.black
                .ignoresSafeArea(.all, edges: .all)
            
            VStack {
                
                if camera.isTaken{
                    
                    HStack {
                        
                        Spacer()
                        
                        
                        Button(action: camera.reTake, label: {
                           
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .foregroundStyle(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        })
                        .padding(.trailing, 10)
                    }
                }
                
                Spacer()
                
                HStack{
                    
                    // if taken showing save and again take button
                    
                    if camera.isTaken{
                        
                        Button(action: {if !camera.isSaved{camera.savePic()}}, label: {
                            Text(camera.isSaved ? "Saved" : "Save")
                                .foregroundStyle(.black)
                                .fontWeight(.semibold)
                                .padding(.vertical, 10)
                                .padding(.horizontal,20)
                                .background(Color.white)
                                .clipShape(Capsule())
                        })
                        .padding(.leading)
                        
                        Spacer()
                        
                    } else {
                        Button(action: camera.takePic, label: {
                            
                            ZStack{
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 65, height: 65)
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 75, height: 75)
                                
                                
                                
                            }
                        })
                    }
                }
                .frame(height: 75)
            }
        }
        .onAppear(perform: {
            camera.Check()
        })
    }
}

// Camera Model
class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    
    @Published var isTaken = false
    
    @Published var session = AVCaptureSession()
    
    @Published var alert = false
    
    // since we're going to read pic data
    @Published var output = AVCapturePhotoOutput()
    
    // preview
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    // Pic data
    @Published var isSaved = false
    
    @Published var picData = Data(count: 0)
    
    func Check() {
        
        // First checking camera has got permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            // Setting Up Session
            
        case .notDetermined:
            // retesting for permission
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                
                if status{
                    self.setUp()
                }
                
            }
        case .denied:
            self.alert.toggle()
            return
            
        default:
            return
        }
    }
    
    func setUp() {
        // setting up camera
        
        do {
            
            // setting configs
            self.session.beginConfiguration()
            
            // change for your own
            let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
                
                let input = try AVCaptureDeviceInput(device: device!)
                
                // checking and adding to session
                
                if self.session.canAddInput(input){
                    self.session.addInput(input)
                }
                
                // same for output
                
                if self.session.canAddOutput(self.output){
                    self.session.addOutput(self.output)
                }
                
                self.session.commitConfiguration()
            //} else {
                //print("No AVCaptureDevice found.")
            //}
            
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    // take and retake functions
    func takePic() {
        
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            self.session.stopRunning()
            
            DispatchQueue.main.async {
                
                withAnimation{self.isTaken.toggle()}
            }
        }
    }
    
    func reTake() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            
            DispatchQueue.main.async {
                withAnimation {self.isTaken.toggle()}
                //clearing
                self.isSaved = false
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?){
        
        if error != nil {
            return
        }
        
        print("picture taken")
        
        guard let imageData = photo.fileDataRepresentation() else {return}
        
        self.isSaved = true
        
        self.picData = imageData
     }
    
    func savePic() {
        
        let image = UIImage(data: self.picData)!
        
        // saving Image
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        print("Saved Successfully")
        
    }
    
}

// setting  view for preview

struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) ->  UIView {
        
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        // Your Own Properties
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        // starting session
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
}*/
