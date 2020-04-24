//
//  ExtensionDelegate.swift
//  sweather-watch Extension
//
//  Created by Sam Davis on 9/2/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import WatchKit
import Alamofire

class ExtensionDelegate: NSObject, WKExtensionDelegate, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        scheduleNextUpdate()
    }
    
    func scheduleNextUpdate() {
        let in10Seconds = Date().addingTimeInterval(60 * 60)
        print("SCHEDULING BG TASK FOR: \(in10Seconds)")
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: in10Seconds, userInfo: nil) { (error) in
            if error != nil {
                print("GOT ERROR FROM BG TASK: \(error!)")
            }
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "watch-app-opened")))
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.sa
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("DID BECOME INVALID WITH ERROR: \(error!)")
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("FINISHED RUNNING BG URL SESSION")
        if let task = self.savedTask {
            task.setTaskCompletedWithSnapshot(false)
        }
    }
    
    var data: Data? = nil
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("Receiving data...")
        if self.data == nil {
            self.data = Data()
        }
        self.data!.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("FINISHED RUNNING BG URL SESSION (didCompleteWithError)")
        if let data = data {
            do {
                self.data = nil
                let result = try JSONDecoder().decode(WWWeatherData.self, from: data)
                let weatherData = SWWeather(weather: result)
                SharedSWWeatherData.shared.weatherData = weatherData
                WatchComplicationHelper.shared.reloadComplications()
                self.scheduleNextUpdate()
            } catch let error {
                print("Got an error \(error)")
            }
        }
        if let task = self.savedTask {
            task.setTaskCompletedWithSnapshot(false)
        }
    }
    
    var savedTask: WKRefreshBackgroundTask?
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        print("GOT NEW BG TASKS: \(backgroundTasks)")
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                savedTask = backgroundTask

                print("RUNNING A BG TASK")
                                
                let api = WillyWeatherAPI()
                let config = URLSessionConfiguration.background(withIdentifier: "com.sjd.sweather.background")
                config.sessionSendsLaunchEvents = true
                let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
                if let locationId = SharedSWWeatherData.shared.weatherData?.location.id {
                    let url = URL(string: api.getWeatherForLocationURL(location: locationId))!
                    let task = session.dataTask(with: url)
                    print("Fetching URL: \(url)")
                    task.resume()
                } else {
                    self.savedTask?.setTaskCompletedWithSnapshot(false)
                }
            
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                print("HANDLING URL SESSION TASK")
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
}
