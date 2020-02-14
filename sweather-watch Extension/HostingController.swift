//
//  HostingController.swift
//  sweather-watch Extension
//
//  Created by Sam Davis on 9/2/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<WatchContentView> {
    override var body: WatchContentView {
        return WatchContentView()
    }
}
