//
//  StormpathTests.swift
//  Stormpath
//
//  Created by Adis on 21/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import XCTest
@testable import Stormpath

class StormpathTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testInitialSetup() {
        // Test that the initial setup stores the data properly
        Stormpath.setUpWithURL("http://localhost:3000")
        XCTAssertNotNil(Stormpath.APIURL)
        Stormpath.cleanUp()
    }
    
}
