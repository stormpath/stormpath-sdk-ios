//
//  StormpathTestsConfiguration.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/18/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

private let env_APIURL = ProcessInfo.processInfo.environment["APIURL"] ?? "https://edjiang.apps.stormpath.io"
let APIURL = URL(string: env_APIURL)!
let timeout = 10.0
let testUsername = "edward@stormpath.com"
let testPassword = "TestTest1"
