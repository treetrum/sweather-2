//
//  SJDFetch.swift
//  sweather-2
//
//  Created by Sam Davis on 10/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation

class SJDFetch {
    
    static let shared = SJDFetch()
    
    var cache = SJDCache(cacheTimeInMins: 15)

    func get(url urlString: String, convertToString: Bool = false, skipCache: Bool = false, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        print("Fetching url: \(urlString)")
        
        let completionHandler: (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void  = { data, response, error in
            if let error = error {
                print("Got an error!: \(error)")
            }
            callback(data, response, error)
            if let data = data {
                self.cache.setCachedData(urlString, data: data)
            }
        }

        if !skipCache, let cachedData = cache.getCachedData(urlString) {
            callback(cachedData, nil, nil)
        } else {
            let url = URL(string: urlString)
            let task = URLSession.shared.dataTask(with: url!, completionHandler: completionHandler)
            task.resume()
        }
    }
}
