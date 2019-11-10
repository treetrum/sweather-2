//
//  DecodeLocalJSON.swift
//  sweather-2
//
//  Created by Sam Davis on 10/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation

func decodeLocalJSON<T: Codable>(_ path: String, type: T.Type) -> T? {
    let url = Bundle.main.url(forResource: path, withExtension: "json")
    if let jsonURL = url {
        do {
            let data = try Data(contentsOf: jsonURL)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(T.self, from: data)
            return jsonData
        } catch {
            return nil
        }
    }
    return nil
}
