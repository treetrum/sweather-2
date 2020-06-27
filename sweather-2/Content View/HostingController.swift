//
//  HostingController.swift
//  sweather-2
//
//  Created by Sam Davis on 25/4/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import SwiftUI

final class HostingController<T: View>: UIHostingController<T> {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
