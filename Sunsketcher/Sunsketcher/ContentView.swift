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
        
        ZStack {
            
            VStack{
                
                Text("Latitude, Longitude:\n\(locationManager.location?.coordinate.latitude ?? 0.0),\(locationManager.location?.coordinate.longitude ?? 0.0)")
                Text("Altitude:\n\(locationManager.location?.altitude ?? 0.0) m").padding()
                //Text("Altitude: \n%.1f m", locationManager.location?.altitude ?? 0.0)
                Text("Timestamp:\n\(Date())")
            }
        }
        
        
       
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() // Location doesn't show in Live Preview - use Simulator
            .environmentObject(LocationManager())
    }
}
