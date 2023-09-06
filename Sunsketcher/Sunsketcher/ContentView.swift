//
//  ContentView.swift
//  Sunsketcher
//
//  Created by ADMIN on 8/25/23.
//

import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        
        ZStack {
            
        
            Color(.gray)
                .ignoresSafeArea()
            
            VStack{
                
                Text("Hello World!").font(.largeTitle).fontWeight(.bold).foregroundColor(Color.white)
                
            }
        }
        
        
       
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
