//
//  Sunset.swift
//  Sunsketcher
//
//  Created by ADMIN on 10/24/23.
//

import Foundation


public class Sunset {
    
    public func calcSun(lat: Double, lon: Double) -> String {
        let timezoneDiff: Int = -timeDiff()
        let date: [Int] = getDate()
        
        let JD: Int = calcJD(date)
        
        //daylight saving time boolean, assumed to be true for this test since it's being tested during daylight saving time so doesn't matter. also doesn't matter for actual eclipse because both October 14 and April 8 are in daylight saving time; false would be 0 though
        let daySaving: Int = 60
        
        var newjd: Double = findRecentSunset()
    }
    
    func getDate() -> [Int] {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let now = Date()
        var date = dateFormatter.string(from: now)
        print("Date: \(date)")
        
        let dateComponents = date.split(separator: "/").map { Int($0) }
        
        return dateComponents.compactMap { $0 }
        
    }
    
    func calcJD(date: [Int]) -> Int {
        if date[1] <= 2 {
            date[0] -= 1
            date[1] += 12
        }
        
        let A: Int = Int(floor(Double(date[0]/100)))
        let B: Int = 2 - A + Int(floor(Double(A/4)))
        
        let JD: Int =
    }
    
    
}
