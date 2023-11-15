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
        
        // Declare the LocToTime and Sunset
        let locToTime: LocToTime = LocToTime()
        let sunset: Sunset = Sunset()
        
        
        // todo: for testing
        // let lat = 31.86361
        // let lon = -102.37163
        
        
        
         //Set eclipseData as the return value from the calculate
        //let eclipseData: [String] = locToTime.calculatefor(lat: lat, lon: lon, alt: alt)
        
        //spoof location for eclipse testing; TODO: remove for actual app releases
        //let eclipseData: [String] = LocToTime.calculatefor(lat: 37.60786, lon: -91.02687, alt: 0); //4/8/2024
        //let eclipseData: [String] = LocToTime.calculatefor(lat: 31.86361, lon: -102.37163, alt: 0); //10/14/2023
        //let eclipseData: [String] = LocToTime.calculatefor(lat: 36.98605, lon: -86.45146, alt: 0); //8/21/2017
        
        //get actual device location for sunset timing (test stuff) TODO: remove for actual app releases
        let sunsetTime: String = Sunset.calcSun(lat: lat, lon: -lon) //make longitude negative as the sunset calculations use a positive westward latitude as opposed to the eclipse calculations using a positive eastward latitude

        
        
        
        //eclipseData is going to be in an array String
        // make sure the user is in the eclipse path
        if /*eclipseData[0] != "N/A"*/ true {
            //let times: Int64 = convertTimes(data: eclipseData)
            let times = convertSunsetTime(data: [sunsetTime, sunsetTime])
            
            // Use the given times to create Calendar objects to use in setting alarms
            var timeCals = [Date(), Date()]
            
            // Set the times in the Calendar objects
            timeCals[0] = Date(timeIntervalSince1970: TimeInterval(times[0]))
            timeCals[1] = Date(timeIntervalSince1970: TimeInterval(times[1]))
            
            // for the final app, might want to add something that makes a countdown timer on screen tick down
             // let details = "You are at lat: \(lat), lon: \(lon); The solar eclipse will start at the following time at your current location: \(timeCals[0].description)" // TODO: use for actual app releases
             let details = "The app will now swap to the camera, where you will have 45 seconds to adjust the phone's position before it starts taking photos." // TODO: remove for actual app releases
             // let details = "lat: \(lat); lon: \(lon); Sunset Time: \(timeCals[0].description)" // TODO: remove for actual app releases
             print("Timing", details)
            
            // button.text = details
             // --------made it visible that something is happening--------

             // store the unix time for the start and end of totality in UserDefaults
             let prefs = UserDefaults.standard
             prefs.setValue(times[0], forKey: "startTime")
             prefs.setValue(times[1], forKey: "endTime")
             prefs.setValue(Float(lat), forKey: "lat")
             prefs.setValue(Float(lon), forKey: "lon")
             prefs.setValue(Float(alt), forKey: "alt")

             // go to camera 60 seconds prior, start taking images 15 seconds prior to 5 seconds after, and then at end of eclipse 5 seconds before and 15 after TODO: also for the sunset timing
             // let date = Date(timeIntervalSince1970: (times[0] - 60)) // TODO: use
             // the next line is a test case to make sure functionality works for eclipse timing
             /*let date = Date(timeIntervalSinceNow: 5) // TODO: remove
             print("SCHEDULE_CAMERA", date.description)

             if timer == nil {
                 print("Timing", "Creating timer.")
                 timer = Timer()
                 let cameraActivitySchedulerTask = TimeTask()
                 timer?.schedule(cameraActivitySchedulerTask, at: date
             }*/

            
            
        } else {
            // Do something if the user isn't in the eclipse path
            // button.text = "Not in eclipse path."
            print("Not in eclipse path.")
            
        }
        
    }
    
    
    
    func convertTimes(data: [String]) -> [Int64] {
        let start = data[0].split(separator: ":").compactMap { Int($0) }
        let end = data[1].split(separator: ":").compactMap { Int($0) }

        // Add the actual time to the Unix time of UTC midnight for the start of that day
        // For April 8
        let startUnix = 1712534400 + (Int64(start[0]) * 3600) + (Int64(start[1]) * 60) + Int64(start[2])
        let endUnix = 1712534400 + (Int64(end[0]) * 3600) + (Int64(end[1]) * 60) + Int64(end[2])
        // For October 14
        //let startUnix: Int64 = 1697241600 + (Int64(start[0]) * 3600) + (Int64(start[1]) * 60) + Int64(start[2])
        //let endUnix: Int64 = 1697241600 + (Int64(end[0]) * 3600) + (Int64(end[1]) * 60) + Int64(end[2])

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
