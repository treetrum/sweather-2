//
//  AppDelegate.swift
//  sweather-2
//
//  Created by Sam Davis on 23/10/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import StoreKit
import SwiftyStoreKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Add firebase
        FirebaseApp.configure()
        
        // Initialise AdMob SDK
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [
            kGADSimulatorID as! String, // Simulator
            "fafcab26bf1f867b3899add5cb2ca1a3" // Sams iPhone 11 Pro
        ];
        GADMobileAds.sharedInstance().start(completionHandler: nil)
                
        // Add SwiftyStoreKit stuff
        SwiftyStoreKit.completeTransactions { (purchases) in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break;
                }
            }
            StoreManager.shared.verifyReciept()
        }
        StoreManager.shared.verifyReciept()
        
        // Setup for UI Testing (wipe db, disable animation, etc)
        if CommandLine.arguments.contains("--UITests") {
            UIView.setAnimationsEnabled(false)
            do {
                let request = NSFetchRequest<SavedLocation>(entityName: "SavedLocation")
                let locations = try self.persistentContainer.viewContext.fetch(request)
                for loc in locations {
                    self.persistentContainer.viewContext.delete(loc)
                }
                try self.persistentContainer.viewContext.save()
                
            } catch {}
        }
        
        // Set default values in database
        do {
            let request = NSFetchRequest<SavedLocation>(entityName: "SavedLocation")
            let locations = try self.persistentContainer.viewContext.fetch(request)
            if locations.count == 0 {
                print("INIT: No locations found")
                let newLocation = SavedLocation(context: self.persistentContainer.viewContext)
                newLocation.id = Int64(4950)
                newLocation.name = "Sydney"
                newLocation.postcode = "2000"
                newLocation.region = "Sydney"
                newLocation.state = "NSW"
                try self.persistentContainer.viewContext.save()
            }
        } catch {
            print("INIT: Error fetching saved locations")
        }
        
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(StoreObserver.shared)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: Core Data Stuff
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UserDataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                // Add your error UI here
                print("[DB] Error loading persistent store")
            }
        }
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("[DB] Could not save context")
                // Show the error here
            }
        }
    }


}

