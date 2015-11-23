//
//  KeychainServiceTest.swift
//  Stormpath
//
//  Created by Adis on 23/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import XCTest
@testable import Stormpath

let testData: String = "testData"
let testDataKey: String = "testDataKey"

class KeychainServiceTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testDataSave() {
        KeychainService.save(testData, key: testDataKey)
        
        let loadedData = KeychainService.loadData(testDataKey)
        
        XCTAssertNotNil(loadedData)
        XCTAssertEqual(loadedData, testData)
    }
    
    // MARK: Performance tests
    
    func testDataSavePerformance() {
        self.measureBlock {
            KeychainService.save(testData, key: testDataKey)
        }
    }
    
    func testDataFetchPerformance() {
        self.measureBlock {
            KeychainService.loadData(testDataKey)
        }
    }
    
}
