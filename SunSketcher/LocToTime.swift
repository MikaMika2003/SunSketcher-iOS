//
//  LocToTime.swift
//  Sunsketcher
//
//  Created by ADMIN on 9/12/23.
//

import Foundation
import SwiftUI

public class LocToTime {
    
    //let locationManager: LocationManager
    
    @State private var obsvconst: [Double] = Array(repeating: 0.0, count: 7)
    
    //Aug. 21, 2017 (for testing)
    public var elements: [Double] = [2457987.268521,  18.0, -4.0, 4.0, 70.3, 70.3,
                                     -0.1295710,   0.5406426, -2.940e-05, -8.100e-06,
                                     0.4854160,  -0.1416400, -9.050e-05,  2.050e-06,
                                     11.8669596,  -0.0136220, -2.000e-06,
                                     89.2454300,  15.0039368,  0.000e-00,
                                     0.5420930,   0.0001241, -1.180e-05,
                                     -0.0040250,   0.0001234, -1.170e-05,
                                     0.0046222,   0.0045992]
    
    var month: [String] = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    
    var c1: [Double] = [Double](repeating: 0.0, count: 41)
    var c2: [Double] = [Double](repeating: 0.0, count: 41)
    var mid: [Double] = [Double](repeating: 0.0, count: 41)
    var c3: [Double] = [Double](repeating: 0.0, count: 41)
    var c4: [Double] = [Double](repeating: 0.0, count: 41)
    
    static var currentTimePeriod = ""
    private static var loadedTimePeriods: [String] = []
    
    // Populate the circumstances array with the time-only dependent circumstances (x, y, d, m, ...)
    func timeDependent(circumstances: [Double]) -> [Double] {
        var newCircumstances = circumstances
        var type: Double
        var index: Int
        var t: Double
        var ans: Double
        
        t = newCircumstances[1]
        index = Int(obsvconst[6])
        
        //Calculate x
        ans = elements[9 + index] * t + elements[8 + index]
        ans = ans * t + elements[7 + index]
        ans = ans * t + elements[6 + index]
        newCircumstances[2] = ans
        
        // Calculate dx
        ans = 3.0 * elements[ 9 + index] * t + 2.0 * elements[8 + index]
        ans = ans * t + elements[7 + index]
        newCircumstances[10] = ans
        
        // Calculate y
        ans = elements[13+index] * t + elements[12 + index]
        ans = ans * t + elements[11 + index]
        ans = ans * t + elements[10 + index]
        newCircumstances[3] = ans;
        
        // Calculate dy
        ans = 3.0 * elements[13 + index] * t + 2.0 * elements[12 + index]
        ans = ans * t + elements[11 + index]
        newCircumstances[11] = ans
        
        // Calculate d
        ans = elements[16 + index] * t + elements[15 + index]
        ans = ans * t + elements[14 + index]
        ans = ans * Double.pi / 180.0
        newCircumstances[4] = ans
        
        // sin d and cos d
        newCircumstances[5] = sin(ans)
        newCircumstances[6] = cos(ans)
        
        // Calculate dd
        ans = 2.0 * elements[16+index] * t + elements[15+index]
        ans = ans * Double.pi / 180.0
        newCircumstances[12] = ans
        
        // Calculate m
        ans = elements[19+index] * t + elements[18+index]
        ans = ans * t + elements[17+index]
        
        if (ans >= 360) {
            ans = ans - 360.0
        }
        
        ans = ans * Double.pi / 180.0
        newCircumstances[7] = ans
        
        // Calculate dm
        ans = 2.0 * elements[19+index] * t + elements[18+index]
        ans = ans * Double.pi / 180.0
        newCircumstances[13] = ans
        
        // Calculate l1 and dl1
        type = newCircumstances[0]
        if ((type == -2) || (type == 0) || (type == 2)) {
            ans = elements[22+index] * t + elements[21+index]
            ans = ans * t + elements[20+index]
            newCircumstances[8] = ans
            newCircumstances[14] = 2.0 * elements[22+index] * t + elements[21+index]
        }
        
        // Calculate l2 and dl2
        if ((type == -1) || (type == 0) || (type == 1)) {
            ans = elements[25+index] * t + elements[24+index]
            ans = ans * t + elements[23+index]
            newCircumstances[9] = ans
            newCircumstances[15] = 2.0 * elements[25+index] * t + elements[24+index]
        }
        
        return newCircumstances
        
    }
    
    // Populate the circumstances array with the time and location dependent circumstances
    func timeLocDependent(circumstances: [Double]) -> [Double] {
        
        var newCircumstances = circumstances
        var index: Int
        var type: Double
        
        timeDependent(circumstances: newCircumstances)
        index = Int(obsvconst[6])
        
        // Calculate h, sin h, cos h
        newCircumstances[16] = newCircumstances[7] - obsvconst[1] - (elements[index+5] / 13713.44)
        newCircumstances[17] = sin(newCircumstances[16])
        newCircumstances[18] = cos(newCircumstances[16])
        
        // Calculate xi
        newCircumstances[19] = obsvconst[5] * newCircumstances[17]
        
        // Calculate eta
        newCircumstances[20] = obsvconst[4] * newCircumstances[6] - obsvconst[5] * newCircumstances[18] * newCircumstances[5]
        
        // Calculate zeta
        newCircumstances[21] = obsvconst[4] * newCircumstances[5] + obsvconst[5] * newCircumstances[18] * newCircumstances[6]
        
        // Calculate dxi
        newCircumstances[22] = newCircumstances[13] * obsvconst[5] * newCircumstances[18]
        
        // Calculate deta
        newCircumstances[23] = newCircumstances[13] * newCircumstances[19] * newCircumstances[5] - newCircumstances[21] * newCircumstances[12]
        
        // Calculate u
        newCircumstances[24] = newCircumstances[2] - newCircumstances[19]
        
        // Calculate v
        newCircumstances[25] = newCircumstances[3] - newCircumstances[20]
        
        // Calculate a
        newCircumstances[26] = newCircumstances[10] - newCircumstances[22]
        
        // Calculate b
        newCircumstances[27] = newCircumstances[11] - newCircumstances[23]
        
        // Calculate l1'
        type = newCircumstances[0]
        if ((type == -2) || (type == 0) || (type == 2)) {
            newCircumstances[28] = newCircumstances[8] - newCircumstances[21] * elements[26+index]
        }
        
        // Calculate l2'
        if ((type == -1) || (type == 0) || (type == 1)) {
            newCircumstances[29] = newCircumstances[9] - newCircumstances[21] * elements[27+index]
        }
        // Calculate n^2
        newCircumstances[30] = newCircumstances[26] * newCircumstances[26] + newCircumstances[27] * newCircumstances[27]
        
        return newCircumstances
    }
    
    // Iterate on C1 or C4
    func c1c4Iterate(circumstances: [Double]) -> [Double] {
        
        var newCircumstances = circumstances
        var sign: Double
        var iter: Int
        var tmp: Double
        var n: Double
        
        timeLocDependent(circumstances: newCircumstances)
        if (newCircumstances[0] < 0) {
            sign = -1.0
        } else {
            sign = 1.0
        }
        
        tmp = 1.0
        iter = 0
        while (((tmp > 0.000001) || (tmp < -0.000001)) && (iter < 50)) {
            n = sqrt(newCircumstances[30])
            tmp = newCircumstances[26] * newCircumstances[25] - newCircumstances[24] * newCircumstances[27]
            tmp = tmp / n / newCircumstances[28]
            tmp = sign * sqrt(1.0 - tmp * tmp) * newCircumstances[28] / n
            tmp = (newCircumstances[24] * newCircumstances[26] + newCircumstances[25] * newCircumstances[27]) / newCircumstances[30] - tmp
            newCircumstances[1] = newCircumstances[1] - tmp
            timeLocDependent(circumstances: newCircumstances)
            iter += 1
        }
        
        return newCircumstances
        
    }
    
    // Get C1 and C4 data
    //   Entry conditions -
    //   1. The mid array must be populated
    //   2. The magnitude at mid eclipse must be > 0.0
    func getc1c4() {
        var tmp: Double
        var n: Double
        
        n = sqrt(mid[30])
        tmp = mid[26] * mid[25] - mid[24] * mid[27]
        tmp = tmp / n / mid[28]
        tmp = sqrt(1.0 - tmp * tmp) * mid[28] / n
        c1[0] = -2
        c4[0] = 2
        c1[1] = mid[1] - tmp
        c4[1] = mid[1] + tmp
        c1c4Iterate(circumstances: c1)
        c1c4Iterate(circumstances: c4)
        
    }
    
    // Iterate on C2 or C3
    func c2c3Iterate(circumstances: [Double]) -> [Double] {
        
        var newCircumstances = circumstances
        var sign: Double
        var iter: Int
        var tmp: Double
        var n: Double

        timeLocDependent(circumstances: newCircumstances)
        if (circumstances[0] < 0) {
            sign = -1.0
        } else {
            sign = 1.0
        }
        if (mid[29] < 0.0) {
            sign = -sign
        }
        tmp = 1.0
        iter = 0
        
        while (((tmp > 0.000001) || (tmp < -0.000001)) && (iter < 50)) {
            n = sqrt(newCircumstances[30])
            tmp = newCircumstances[26] * newCircumstances[25] - newCircumstances[24] * newCircumstances[27]
            tmp = tmp / n / newCircumstances[29]
            tmp = sign * sqrt(1.0 - tmp * tmp) * newCircumstances[29] / n
            tmp = (newCircumstances[24] * newCircumstances[26] + newCircumstances[25] * newCircumstances[27]) / newCircumstances[30] - tmp
            newCircumstances[1] = newCircumstances[1] - tmp
            
            timeLocDependent(circumstances: newCircumstances)
            iter += 1
        }
        
        return circumstances
    }
    
    // Get C2 and C3 data
    //   Entry conditions -
    //   1. The mid array must be populated
    //   2. There must be either a total or annular eclipse at the location!
    func getc2c3() {
        var tmp: Double
        var n: Double
        
        n = sqrt(mid[30])
        tmp = mid[26] * mid[25] - mid[24] * mid[27]
        tmp = tmp / n / mid[29]
        tmp = sqrt(1.0 - tmp * tmp) * mid[29] / n
        c2[0] = -1
        c3[0] = 1
        
        if (mid[29] < 0.0) {
            c2[1] = mid[1] + tmp
            c3[1] = mid[1] - tmp
        } else {
            c2[1] = mid[1] - tmp
            c3[1] = mid[1] + tmp
        }
        c2c3Iterate(circumstances: c2)
        c2c3Iterate(circumstances: c3)
        
    }
    
    // Get the observational circumstances
    func observational(circumstances: [Double]) {
        
        var newCircumstances = circumstances
        var contactType: Double
        var cosLat: Double
        var sinLat: Double
        
        // We are looking at an "external" contact UNLESS this is a total eclipse AND we are looking at
        // c2 or c3, in which case it is an INTERNAL contact! Note that if we are looking at mid eclipse,
        // then we may not have determined the type of eclipse (mid[39]) just yet!
        
        if (newCircumstances[0] == 0) {
            contactType = 1.0
        } else {
            if ((mid[39] == 3) && ((newCircumstances[0] == -1) || (newCircumstances[0] == 1))) {
              contactType = -1.0
            } else {
              contactType = 1.0
            }
        }
        
        // Calculate p
        newCircumstances[31] = atan2(contactType * newCircumstances[24], contactType * newCircumstances[25])
                                       
        // Calculate alt
        sinLat = sin(obsvconst[0])
        cosLat = cos(obsvconst[0])
        newCircumstances[32] = asin(newCircumstances[5] * sinLat + newCircumstances[6] * cosLat * newCircumstances[18])
                                     
        // Calculate q
        newCircumstances[33] = asin(cosLat * newCircumstances[17] / cos(newCircumstances[32]))
        if (newCircumstances[20] < 0.0) {
            newCircumstances[33] = Double.pi - newCircumstances[33]
        }
                                     
        // Calculate v
        newCircumstances[34] = newCircumstances[31] - newCircumstances[33]
                                     
        // Calculate azi
        newCircumstances[35] = atan2(-1.0 * newCircumstances[17] * newCircumstances[6], newCircumstances[5] * cosLat - newCircumstances[18] * sinLat * newCircumstances[6])
                                     
        // Calculate visibility
        if (newCircumstances[32] > -0.00524) {
            newCircumstances[40] = 0
        } else {
            newCircumstances[40] = 1
        }
    }
    
    // Get the observational circumstances for mid eclipse
    func midobservational() {
        observational(circumstances: mid)
        
        // Calculate m, magnitude and moon/sun
        mid[36] = sqrt(mid[24] * mid[24] + mid[25] * mid[25])
        mid[37] = (mid[28] - mid[36]) / (mid[28] + mid[29])
        mid[38] = (mid[28] - mid[29]) / (mid[28] + mid[29])
        
    }
    
    
    // Calculate mid eclipse
    func getmid() {
        var iter: Int
        var tmp: Double

        mid[0] = 0.0
        mid[1] = 0.0
        iter = 0
        tmp = 1.0
        timeLocDependent(circumstances: mid)
      
        while (((tmp > 0.000001) || (tmp < -0.000001)) && (iter < 50)) {
            tmp = (mid[24] * mid[26] + mid[25] * mid[27]) / mid[30]
            mid[1] = mid[1] - tmp
            iter += 1
            timeLocDependent(circumstances: mid)
        }
    }
    
    // Calculate the time of sunrise or sunset
    func getsunriset(circumstances: [Double], riset: Double) {
        var newCircumstances = circumstances
        var h0: Double
        var diff: Double
        var iter: Int

        diff = 1.0;
        iter = 0;
        while ((diff > 0.00001) || (diff < -0.00001)) {
            iter += 1
            if (iter == 4) {return}
            h0 = acos((sin(-0.00524) - sin(obsvconst[0]) * newCircumstances[5]) / cos(obsvconst[0]) / newCircumstances[6])
            diff = (riset * h0 - newCircumstances[16]) / newCircumstances[13]
            while (diff >= 12.0) {diff -= 24.0}
            while (diff <= -12.0) {diff += 24.0}
            newCircumstances[1] += diff
            timeLocDependent(circumstances: newCircumstances)
        }
    }
    
    
    // Calculate the time of sunrise
    func getsunrise(circumstances: [Double]) {
        var newCircumstances = circumstances
        getsunriset(circumstances: newCircumstances, riset: -1.0)
    }
    
    // Calculate the time of sunset
    func getsunset(circumstances: [Double]) {
        var newCircumstances = circumstances
        getsunriset(circumstances: newCircumstances, riset: 1.0)
    }
    
    
    // Copy a set of circumstances
    func copycircumstances(circumstancesfrom: [Double], circumstancesto: [Double]) {
        var i: Int
        var circumstances1 = circumstancesfrom
        var circumstances2 = circumstancesto

        for i in 1..<41 {
            circumstances2[i] = circumstances1[i]
        }
    }
    
    func getall() {
        getmid()
            
        //observational(mid);
        // Calculate m, magnitude and moon/sun
        midobservational()
        
        if (mid[37] > 0.0) {
            getc1c4()
            
            if ((mid[36] < mid[29]) || (mid[36] < -mid[29])) {
                getc2c3()
            
                if (mid[29] < 0.0) {
                    mid[39] = 3 // Total eclipse
                } else {
                    mid[39] = 2 // Annular eclipse
                }
                observational(circumstances: c2)
                observational(circumstances: c3)
              
                c2[36] = 999.9
                c3[36] = 999.9
            } else {
                mid[39] = 1; // Partial eclipse
            }
            observational(circumstances: c1)
            observational(circumstances: c4)
        } else {
            mid[39] = 0 // No eclipse
        }
    }

    // Read the data that's in the form, and populate the obsvconst array
    func calcObsv(lat: Double, lon: Double, alt: Double) {
        var tmp: Double
      
        //latitude
        obsvconst[0] = lat * Double.pi / 180.0
      
        //longitude
        obsvconst[1] = lon * Double.pi / 180.0 * -1

        //altitude
        obsvconst[2] = alt

        //timezone is always 0 for these calculations, will convert after
        obsvconst[3] = 0

        // Get the observer's geocentric position
        tmp = atan(0.99664719 * tan(obsvconst[0]))
        obsvconst[4] = 0.99664719 * sin(tmp) + (obsvconst[2] / 6378140.0) * sin(obsvconst[0])
        obsvconst[5] = cos(tmp) + (obsvconst[2] / 6378140.0 * cos(obsvconst[0]))

        //the original code had a list of all besellian elements for a large number of eclipses, but this app currently only needs the elements for the April 8 2024 eclipse, so we set it to 0
        obsvconst[6] = 0

    }

    // Get the local date of an event
    func getdate(circumstances: [Double]) -> String {
        var newCircumstances = circumstances
        var t: Double
        var ans: String
        var jd: Double
        var a: Double
        var b: Double
        var c: Double
        var d: Double
        var e: Double
        var index: Int
        

        index = Int(obsvconst[6])
        
        // Calculate the JD for noon (TDT) the day before the day that contains T0
        jd = floor(elements[index] - (elements[1 + index] / 24.0))
        
        // Calculate the local time (ie the offset in hours since midnight TDT on the day containing T0).
        t = newCircumstances[1] + elements[1 + index] - obsvconst[3] - (elements[4 + index] - 0.5) / 3600.0
        if (t < 0.0) {
            jd -= 1
        }
        if (t >= 24.0) {
            jd += 1
        }
        if (jd >= 2299160.0) {
            a = floor((jd - 1867216.25) / 36524.25)
            a = jd + 1 + a - floor(a/4)
        } else {
            a = jd
        }
        b = a + 1525.0
        c = floor((b-122.1)/365.25)
        d = floor(365.25 * c)
        e = floor((b - d) / 30.6001)
        d = b - d - floor(30.6001 * e)
        if (e < 13.5) {
            e = e - 1
        } else {
            e = e - 13
        }
        if (e > 2.5) {
            ans = "\(Int(c - 4716))-"
        } else {
            ans = "\(Int(c - 4715))-"
        }
        ans += month[Int(e-1)] + "-"
        if (d < 10) {
            ans += "0"
        }
        ans += "\(d)"
        return ans
    }

    
    // Get the local time of an event
    func gettime(circumstances: [Double]) -> String {
        var newCircumstances = circumstances
        var t: Double
        var ans: String
        var index: Int

        ans = ""
        index = Int(obsvconst[6])
        t = newCircumstances[1] + elements[1 + index] - obsvconst[3] - (elements[4 + index] - 0.5) / 3600.0
        if (t < 0.0) {
            t = t + 24.0
        }
        if (t >= 24.0) {
            t = t - 24.0
        }
        if (t < 10.0) {
            ans += "0"
        }
        ans += "\(Int(floor(t))):"
        t = (t * 60.0) - 60.0 * floor(t)
        if (t < 10.0) {
            ans += "0"
        }
        ans += "\(Int(floor(t)))"
        if (newCircumstances[40] <= 1) { // not sunrise or sunset
            ans += ":"
            t = (t * 60.0) - 60.0 * floor(t)
            if (t < 10.0) {
                ans += "0"
            }
            ans += "\(Int(floor(t)))"
        }

        return ans
    }

    //the next five methods aren't currently used but I'm leaving them in because they may be useful later on
    // Get the altitude
    func getalt(circumstances: [Double]) -> String {
        var newCircumstances = circumstances
        var t: Double
        var ans: String
        

        if (newCircumstances[40] == 2) {
            return "0(r)"
        }
        if (newCircumstances[40] == 3) {
            return "0(s)"
        }
        if ((newCircumstances[32] < 0.0) && (newCircumstances[32] >= -0.00524)) {
            // Crude correction for refraction (and for consistency's sake)
            t = 0.0
        } else {
            t = newCircumstances[32] * 180.0 / Double.pi
        }
        if (t < 0.0) {
            ans = "-"
            t = -t
        } else {
            ans = ""
        }
        t = floor(t + 0.5)
        if (t < 10.0) {
            ans += "0"
        }
        ans += "\(t)"
        return ans
    }

    
    // Get the azimuth
    func getazi(circumstances: [Double]) -> String {
        var newCircumstances = circumstances
        var t: Double
        var ans: String

        ans = ""
        t = newCircumstances[35] * 180.0 / Double.pi
        if (t < 0.0) {
            t = t + 360.0
        }
        if (t >= 360.0) {
            t = t - 360.0
        }
        t = floor(t + 0.5)
        if (t < 100.0) {
            ans += "0"
        }
        if (t < 10.0) {
            ans += "0"
        }
        ans += "\(t)"

        return ans
    }

    //
    // Get the duration in mm:ss.s format
    //
    // Adapted from code written by Stephen McCann - 27/04/2001
    func getduration() -> String {
        var tmp: Double
        var ans: String
      
        if (c3[40] == 4) {
            tmp = mid[1] - c2[1]
        } else if (c2[40] == 4) {
            tmp = c3[1] - mid[1]
        } else {
            tmp = c3[1] - c2[1]
        }
        if (tmp < 0.0) {
            tmp = tmp + 24.0
        } else if (tmp >= 24.0) {
            tmp = tmp - 24.0
        }
        tmp = (tmp * 60.0) - 60.0 * floor(tmp) + 0.05 / 60.0
        ans = "\(floor(tmp))m"
        tmp = (tmp * 60.0) - 60.0 * floor(tmp)
        if (tmp < 10.0) {
            ans += "0"
        }
        ans += "\(floor(tmp))s"
        return ans
    }

    //
    // Get the magnitude
    func getmagnitude() -> String {
        var a: String

        a = String(format: "%.3f", floor(1000.0 * mid[37] + 0.5) / 1000.0)
        //a = Double.toString(floor(1000.0 * mid[37] + 0.5) / 1000.0)

        if (mid[40] == 2) {
            a += "(r)"
        }
        if (mid[40] == 3) {
            a += "(s)"
        }
        return a
    }

    //
    // Get the coverage
    func getcoverage() -> String {
        var a: String
        var b: Double
        var c: Double

        if (mid[37] <= 0.0) {
            a = "0.0"
        } else if (mid[37] >= 1.0) {
            a = "1.000"
        } else {
            if (mid[39] == 2) {
                c = mid[38] * mid[38]
            } else {
                c = acos((mid[28] * mid[28] + mid[29] * mid[29] - 2.0 * mid[36] * mid[36]) / (mid[28] * mid[28] - mid[29] * mid[29]))
                b = acos((mid[28] * mid[29] + mid[36] * mid[36]) / mid[36] / (mid[28] + mid[29]))
                a = String(format: "%.3f", Double.pi - b - c)
                //Double.toString(Double.pi - b - c)
                c = ((mid[38] * mid[38] * Double(a)! + b) - mid[38] * sin(c)) / Double.pi
                
            }
            a = String(format: "%.3f", floor(1000.0 * c + 0.5) / 1000.0)
            //Double.toString(floor(1000.0 * c + 0.5) / 1000.0)
        }
        if (mid[40] == 2) {
            a += "(r)"
        }
        if (mid[40] == 3) {
            a += "(s)"
        }
        return a
    }

    func calculatefor(lat: Double, lon: Double, alt: Double) -> [String] {
        var info = [String]()
        
        calcObsv(lat: lat, lon: lon, alt: alt)
        //calcObsv(lat, lon, alt)
        //calcObsv(25.122, -104.2252, alt);

        getall()
        
        if(mid[39] > 2){
            info[0] = gettime(circumstances: c2)
            info[1] = gettime(circumstances: c3)
            print("LocationTiming \(info[0]);   \(info[1])")
        }
        else {return ["N/A"]}
        
        return info
    }
    
}
