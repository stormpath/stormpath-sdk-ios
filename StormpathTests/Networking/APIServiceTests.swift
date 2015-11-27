//
//  APIServiceTests.swift
//  Stormpath
//
//  Created by Adis on 20/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import XCTest
@testable import Stormpath

class APIServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        Stormpath.cleanUp()
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testAPIExistsAtGivenURL() {
        Stormpath.setUpWithURL("http://localhost:3000/")
        XCTAssertNotNil(Stormpath.APIURL)
        
        let URL = NSURL(string: Stormpath.APIURL!)
        XCTAssertNotNil(URL)
        
        let expectation = expectationWithDescription("GET \(URL)")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(URL!) { data, response, error in
            XCTAssertNotNil(data, "data should not be nil")
            XCTAssertNil(error, "error should be nil")
            
            if let HTTPResponse = response as? NSHTTPURLResponse {
                XCTAssertEqual(HTTPResponse.statusCode, 200, "HTTP response status code should be 200")
            } else {
                XCTFail("Response was not NSHTTPURLResponse")
            }
            
            expectation.fulfill()
        }
        
        task.resume()
        
        waitForExpectationsWithTimeout(task.originalRequest!.timeoutInterval) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            
            task.cancel()
        }
    }
    
    func testAPIExistsAtGivenURLWithTrailingSlash() {
        Stormpath.setUpWithURL("http://localhost:3000/")
        XCTAssertNotNil(Stormpath.APIURL)
        
        let URL = NSURL(string: Stormpath.APIURL!)
        XCTAssertNotNil(URL)
        
        let expectation = expectationWithDescription("GET \(URL)")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(URL!) { data, response, error in
            XCTAssertNotNil(data, "data should not be nil")
            XCTAssertNil(error, "error should be nil")
            
            if let HTTPResponse = response as? NSHTTPURLResponse {
                XCTAssertEqual(HTTPResponse.statusCode, 200, "HTTP response status code should be 200")
            } else {
                XCTFail("Response was not NSHTTPURLResponse")
            }
            
            expectation.fulfill()
        }
        
        task.resume()
        
        waitForExpectationsWithTimeout(task.originalRequest!.timeoutInterval) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            
            task.cancel()
        }
    }
    
    // MARK: Tests - Data parsing
    
//    func testValidRegisterResponseParsing() {
//        
//        
//    }
    
    func testValidLoginResponseParsing() {
        Stormpath.setUpWithURL("http://localhost:3000/")
        
        let validResponse: String = "{\"access_token\":\"accessToken\",\"refresh_token\":\"refreshToken\"}"
//        let validResponse: String = "{\"access_token\":\"accessToken\",\"refresh_token\":\"refreshToken\",\"token_type\":\"Bearer\",\"expires_in\":3600,\"stormpath_access_token_href\":\"https://api.stormpath.com/v1/accessTokens/tokens\"}"
        let validData: NSData = validResponse.dataUsingEncoding(NSUTF8StringEncoding)!
        
        APIService.parseLoginResponseData(validData, error: nil) { (accessToken, error) -> Void in
            // Confirm that parsing was successful
            XCTAssertNil(error)
            XCTAssertNotNil(accessToken)
            XCTAssertEqual(accessToken, "accessToken")
            
            // Confirm that values are stored in Keychain properly
            XCTAssertEqual("accessToken", KeychainService.accessToken)
            XCTAssertEqual("refreshToken", KeychainService.refreshToken)
        }
        
    }
    
}
