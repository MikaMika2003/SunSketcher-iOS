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
        
        var lat = locationManager.location?.coordinate.latitude ?? 0.0
        var lon = locationManager.location?.coordinate.longitude ?? 0.0
        var alt = locationManager.location?.altitude ?? 0.0
        
        // Declare the LocToTime
        let locToTime: LocToTime = LocToTime()
        
        
        
        // todo: for testing
        // let lat = 31.86361
        // let lon = -102.37163
        
        
        
         //Set eclipseData as the return value from the calculate
        let eclipseData: [String] = locToTime.calculatefor(lat: lat, lon: lon, alt: alt)
        
        //spoof location for eclipse testing; TODO: remove for actual app releases
        //let eclipseData: [String] = LocToTime.calculatefor(lat: 37.60786, lon: -91.02687, alt: 0); //4/8/2024
        //let eclipseData: [String] = LocToTime.calculatefor(lat: 31.86361, lon: -102.37163, alt: 0); //10/14/2023
        //let eclipseData: [String] = LocToTime.calculatefor(lat: 36.98605, lon: -86.45146, alt: 0); //8/21/2017
        
        //get actual device location for sunset timing (test stuff) TODO: remove for actual app releases
        //String sunsetTime = Sunset.calcSun(lat, -lon); //make longitude negative as the sunset calculations use a positive westward latitude as opposed to the eclipse calculations using a positive eastward latitude

        
        
        
        //eclipseData is going to be in an array String
        // make sure the user is in the eclipse path
        /*if eclipseData[0] != "N/A" {
            let times = convertTimes(data: eclipseData)
            let times = convertSunsetTime(data: [sunsetT])
            
            
        } else {
            // Do something if the user isn't in the eclipse path
            
            
        }*/
        
        
    }
    
    func convertTimes(data: [String]) -> [Int64] {
        let start = data[0].split(separator: ":").compactMap { Int($0) }
        let end = data[1].split(separator: ":").compactMap { Int($0) }

        // Add the actual time to the Unix time of UTC midnight for the start of that day
        // For April 8
        // let startUnix = 1712534400 + (Int64(start[0]) * 3600) + (Int64(start[1]) * 60) + Int64(start[2])
        // let endUnix = 1712534400 + (Int64(end[0]) * 3600) + (Int64(end[1]) * 60) + Int64(end[2])
        // For October 14
        let startUnix: Int64 = 1697241600 + (Int64(start[0]) * 3600) + (Int64(start[1]) * 60) + Int64(start[2])
        let endUnix: Int64 = 1697241600 + (Int64(end[0]) * 3600) + (Int64(end[1]) * 60) + Int64(end[2])

        return [startUnix, endUnix]
    }
    
    func convertSunsetTime(data: [String]) -> [Int64] {
        let start = data[0].split(separator: ":").compactMap { Int($0) }
        let end = data[1].split(separator: ":").compactMap { Int($0) }

        // Get the current time in seconds, remove a day if it is past UTC midnight for the date that your timezone is currently in
        var currentDateUnix = Int64(Date().timeIntervalSince1970)
        let currentTimeUnix = currentDateUnix % 86400
        if currentTimeUnix > 0 && currentTimeUnix < 5 * 60 * 60 {
            print("Current time is past UTC midnight; Subtracting a day from time estimate")
            currentDateUnix -= 86400
        }

        let currentDateTimezoneCorrectedUnix = currentDateUnix - (currentDateUnix % (60 * 60 * 24)) // - (5 * 60 * 60) // Add this +5 hours back for sunset tests

        // Convert the given time to seconds, add it to the start of the day as calculated by
        
        let startUnix: Int64 = currentDateTimezoneCorrectedUnix + Int64(start[0] * 3600) + Int64(start[1] * 60) + Int64(start[2])
        let endUnix: Int64 = currentDateTimezoneCorrectedUnix + Int64(end[0] * 3600) + Int64(end[1] * 60) + Int64(end[2])

        return [startUnix, endUnix]
    }

        

    
    
}
