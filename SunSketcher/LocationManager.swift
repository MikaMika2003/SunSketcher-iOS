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
        
        // Declare the LocToTime
        let locToTime: LocToTime = LocToTime()
        
        // Set result as the return value from the calculate
        let result = locToTime.calculatefor(lat: locationManager.location?.coordinate.latitude ?? 0.0, lon: locationManager.location?.coordinate.longitude ?? 0.0, alt: locationManager.location?.altitude ?? 0.0)
        
        //result is going to be in an array String
        /*if result == ["N/A"] {
             // Do something if the user isn't in an area in view of the eclipse
            
            
        } else {
            // Convert from string array to
            let info = result[1]
            
            result[1] =
        }
        */
        
    }
    
    func convertTimeStringsToDates(timeStrings: [String]) -> [Date] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        
        var dateArray: [Date] = []
        
        for timeString in timeStrings {
            if let date = dateFormatter.date(from: timeString) {
                dateArray.append(date)
            }
        }
        
        return dateArray
        
    }
    
    
}
