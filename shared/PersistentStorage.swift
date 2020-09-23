//
//  PersistentStorage.swift
//  sweather-2
//
//  Created by Sam Davis on 23/9/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import Foundation
import CoreData

public extension URL {

    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}


class PersistentStorage {
    
    public static var context: NSManagedObjectContext {
      return persistentContainer.viewContext
    }
    
    public static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UserDataModel")
        let storeURL = URL.storeURL(for: "group.sweather.coredata", databaseName: "UserDataModel")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                // Add your error UI here
                print("[DB] Error loading persistent store")
            }
        }
        return container
    }()
    
    public static func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("[DB] Could not save context")
            }
        }
    }

}
