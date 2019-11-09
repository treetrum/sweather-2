//
//  WWLocation.swift
//  sweather-2
//
//  Created by Sam Davis on 10/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation

struct WWLocation: Codable {
    let id: Int
    let name: String
    let region: String
    let state: String
    let postcode: String
}
