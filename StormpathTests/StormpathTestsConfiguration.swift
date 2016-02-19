//
//  StormpathTestsConfiguration.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/18/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

private let env_APIURL = NSProcessInfo.processInfo().environment["APIURL"] ?? ""
let APIURL = NSURL(string: env_APIURL) ?? NSURL(string: "http://localhost:3000")!
let timeout = 5.0
let testUsername = "test@example.com"
let testPassword = "TestTest1"
