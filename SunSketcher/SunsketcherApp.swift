//
//  SunSketcherApp.swift
//  SunSketcher
//
//  Created by ADMIN on 8/25/23.
//

import SwiftUI

@main
struct SunSketcherApp: App {
    @StateObject var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
            //CameraUI()
        }
        
        
    }
}
