//
//  StormpathTests.swift
//  Stormpath
//
//  Created by Adis on 21/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import XCTest
@testable import Stormpath

internal let APIURL: String = "http://localhost:3000"

class StormpathTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        
        KeychainService.accessToken = nil
        KeychainService.refreshToken = nil
    }
    
    // MARK: Tests
    
}
