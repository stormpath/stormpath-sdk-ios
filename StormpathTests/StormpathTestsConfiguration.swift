//
//  StormpathTestsConfiguration.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/18/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

private let env_APIURL = ProcessInfo.processInfo.environment["APIURL"] ?? "http://localhost:3000"
let APIURL = URL(string: env_APIURL)!
let timeout = 5.0
let testUsername = "test@example.com"
let testPassword = "TestTest1"
