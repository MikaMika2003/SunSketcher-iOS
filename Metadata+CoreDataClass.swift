//
//  Metadata+CoreDataClass.swift
//  Sunsketcher
//
//  Created by Admin on 1/4/24.
//
//

import Foundation
import CoreData
import UIKit

@objc(Metadata)
public class Metadata: NSManagedObject {
    
    
}

class MetadataDAO {
    static let shared = MetadataDAO()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Metadata")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    func getAllImageMetas() -> [Metadata] {
        let fetchRequest: NSFetchRequest<Metadata> = Metadata.fetchRequest()
        
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching metadata: \(error.localizedDescription)")
            return []
        }
    }
    
    func addImageMeta(filepath: String, latitude: Double, longitude: Double, altitude: Double, captureTime: Int64) {
        let metadata = Metadata(context: persistentContainer.viewContext)
        metadata.filepath = filepath
        metadata.latitude = latitude
        metadata.longitude = longitude
        metadata.altitude = altitude
        metadata.captureTime = captureTime
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Error saving metadata: \(error.localizedDescription)")
        }
    }
}
