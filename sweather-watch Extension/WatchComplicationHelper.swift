//
//  WatchComplicationHelper.swift
//  sweather-2
//
//  Created by Sam Davis on 9/2/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import Foundation

#if os(watchOS)

import WatchKit

class WatchComplicationHelper {
    static var shared = WatchComplicationHelper()
    public func reloadComplications() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        if let complications = complicationServer.activeComplications {
            for complication in complications {
                complicationServer.reloadTimeline(for: complication)
            }
        }
    }
}

#endif

