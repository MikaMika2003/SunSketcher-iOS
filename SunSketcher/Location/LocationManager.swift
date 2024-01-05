//
//  LocationManager.swift
//  Sunsketcher
//
//  Created by ADMIN on 9/6/23.
//

import Foundation
import MapKit
import CoreLocation

@MainActor
class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    //@Published var altitude: CLLocationDistance {get}
    
    static let shared = LocationManager()
    
    var timer: Timer?
    
    private var locationCallback: ((CLLocation) -> Void)?
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation() // Remember to update Info.plist
        locationManager.delegate = self
        
    }
    
    func requestLocationUpdate(callback: @escaping (CLLocation) -> Void) {
        locationCallback = callback
        locationManager.startUpdatingLocation()
    }
    

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //guard let location = locations.last else {return}
        //self.location = location
        //self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        //let altitude = location.altitude
        //let altitude = self.location?.altitude
        
        if let lastLocation = locations.last {
            let altitude = lastLocation.altitude
            self.location = lastLocation
            self.region = MKCoordinateRegion(center: lastLocation.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
            
        }
        
    }
        

    
    
}
