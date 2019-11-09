//
//  SJDCache.swift
//  sweather-2
//
//  Created by Sam Davis on 10/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation

struct SJDCache {
    
    let cacheTimeInMins: Double
    
    struct CachedItem {
        var cacheTimeInMinutes: Double
        let url: String
        let data: Data
        let fetchedTime: Date
        var cacheExpiryTime: Date {
            get {
                return fetchedTime.addingTimeInterval(cacheTimeInMinutes*60)
            }
        }
        var isCacheCurrent: Bool {
            get {
                return Date() <= cacheExpiryTime
            }
        }
    }
    var caches = [String: CachedItem]()
    
    mutating func getCachedData(_ url: String) -> Data? {
        if let cache = self.caches[url] {
            if cache.isCacheCurrent {
                return cache.data
            } else {
                caches.removeValue(forKey: url)
            }
        }
        return nil
    }
    
    mutating func setCachedData(_ url: String, data: Data) {
        self.caches[url] = CachedItem(cacheTimeInMinutes: cacheTimeInMins, url: url, data: data, fetchedTime: Date())
    }
}
