//
//  CameraControl.swift
//  Sunsketcher
//
//  Created by ADMIN on 9/20/23.
//

import Foundation
import AVFoundation
import UIKit

class CameraControl: UIViewController, AVCapturePhotoCaptureDelegate {
    
    
    let session = AVCaptureSession()
    var camera: AVCaptureDevice?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var cameraCaptureOutput: AVCapturePhotoOutput?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCaptureSession()
    }
    
    func initializeCaptureSession() {
        
        session.sessionPreset = AVCaptureSession.Preset.high
        camera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let cameraCaptureInput = try AVCaptureDeviceInput(device: camera!)
            cameraCaptureOutput = AVCapturePhotoOutput()
            
            session.addInput(cameraCaptureInput)
            //session.addOutput(cameraCaptureOutput)
        } catch {
            print(error.localizedDescription)
        }
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.bounds
        //cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait \\ Change because videoOrientation is deprecated
        
        //view.layer.insertSublayer(cameraPreviewLayer, at: 0)
        
        
    }

}

