//
//  Metadata+CoreDataProperties.swift
//  Sunsketcher
//
//  Created by Admin on 1/4/24.
//
//

import Foundation
import CoreData


extension Metadata {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Metadata> {
        return NSFetchRequest<Metadata>(entityName: "Metadata")
    }

    @NSManaged public var altitude: Double
    @NSManaged public var captureTime: Int64
    @NSManaged public var filepath: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var id: Int64
    
    var autoIncrementedID: Int64 {
        let existingID = self.id
        self.id += 1
        return existingID
    }
    

}

extension Metadata : Identifiable {

}
