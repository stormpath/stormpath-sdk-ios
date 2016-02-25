//
//  KeychainServiceTests.swift
//  Stormpath
//
//  Created by Adis on 23/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import XCTest
@testable import Stormpath

let testData: String = "testData"
let testDataKey: String = "testDataKey"

class KeychainServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        super.tearDown()
        
        KeychainService.accessToken = nil
        KeychainService.refreshToken = nil
    }
    
    // MARK: Tests
    
    func testDataSave() {
        // First clean the saved data
        KeychainService.saveString(nil, key: testDataKey)
        XCTAssertNil(KeychainService.stringForKey(testDataKey))
        
        KeychainService.saveString(testData, key: testDataKey)
        
        let loadedData = KeychainService.stringForKey(testDataKey)
        
        XCTAssertNotNil(loadedData)
        XCTAssertEqual(loadedData, testData)
    }
    
}
