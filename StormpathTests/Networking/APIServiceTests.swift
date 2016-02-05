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
    var stormpath = Stormpath.sharedSession
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        
        KeychainService.accessToken = nil
        KeychainService.refreshToken = nil
    }
    
    // MARK: Tests
    
    // This will test that the API exists at the URL used for testing
    func testAPIExistsAtGivenURL() {
        
        let URL = stormpath.configuration.APIURL
        XCTAssertNotNil(URL)
        
        let expectation = expectationWithDescription("GET \(URL)")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(URL) { data, response, error in
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
    
    // Same as above, but this one makes sure the trailing slash doesn't create odd strings
    func testAPIExistsAtGivenURLWithTrailingSlash() {
        
        let URL = stormpath.configuration.APIURL
        XCTAssertNotNil(URL)
        
        let expectation = expectationWithDescription("GET \(URL)")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(URL) { data, response, error in
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
    
    // MARK: Test register responses
    
    // Test that the valid response produces a valid dictionary
    func testValidRegisterResponseParsing() {
        
        let validResponse: String = "{\"email\":\"user@stormpath.com\",\"password\":\"Password1\",\"username\":\"user@stormpath.com\"}"
        let validData: NSData = validResponse.dataUsingEncoding(NSUTF8StringEncoding)!
        
        APIService.parseDictionaryResponseData(validData) { (userDictionary, error) -> Void in
            XCTAssertNotNil(userDictionary)
            XCTAssertNil(error)
        }
    }
    
    // Invalid response should not produce a dictionary but an error
    func testInvalidRegisterResponseParsing() {
        
        let invalidResponse = "this_should_not_work"
        let invalidData = invalidResponse.dataUsingEncoding(NSUTF8StringEncoding)!
        
        APIService.parseDictionaryResponseData(invalidData) { (userDictionary, error) -> Void in
            XCTAssertNil(userDictionary)
            XCTAssertNotNil(error)
        }
    }
    
    // This one tests no data given in a response
    func testErrorRegisterResponseParsing() {
        
        APIService.parseDictionaryResponseData(nil) { (userDictionary, error) -> Void in
            XCTAssertNil(userDictionary)
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: Test registration header parsing
    
    func testEmptyHeadersInRegistration() {
        KeychainService.accessToken = nil
        KeychainService.refreshToken = nil

        let response: NSHTTPURLResponse = NSHTTPURLResponse.init(URL: StormpathConfiguration.defaultConfiguration.APIURL, statusCode: 200, HTTPVersion: "", headerFields: ["":""])!
        APIService.parseRegisterHeaderData(response)
        
        // Invalid headers should not parse anything
        XCTAssertNil(KeychainService.accessToken)
        XCTAssertNil(KeychainService.refreshToken)
    }
    
    // MARK: Test login and refresh token responses
    
    // Test that the valid login response returns the access_token, and stores both access_token and refresh_token properly
    func testValidLoginResponseParsing() {
        
        let validResponse: String = "{\"access_token\":\"accessToken\",\"refresh_token\":\"refreshToken\",\"token_type\":\"Bearer\",\"expires_in\":3600,\"stormpath_access_token_href\":\"https://api.stormpath.com/v1/accessTokens/tokens\"}"
        let validData: NSData = validResponse.dataUsingEncoding(NSUTF8StringEncoding)!
        
        APIService.parseLoginResponseData(validData) { (accessToken, error) -> Void in
            // Confirm that parsing was successful
            XCTAssertNil(error)
            XCTAssertNotNil(accessToken)
            XCTAssertEqual(accessToken, "accessToken")
            
            // Confirm that values are stored in Keychain properly
            XCTAssertEqual("accessToken", KeychainService.accessToken)
            XCTAssertEqual(KeychainService.accessToken, self.stormpath.accessToken)
            XCTAssertEqual("refreshToken", KeychainService.refreshToken)
        }
    }
    
    // Invalid JSON should not store either access_token or refresh_token
    func testInvalidLoginResponseParsing() {
        
        let invalidResponse = "this_should_not_work"
        let invalidData = invalidResponse.dataUsingEncoding(NSUTF8StringEncoding)!
        
        APIService.parseLoginResponseData(invalidData) { (accesToken, error) -> Void in
            XCTAssertNil(accesToken)
            XCTAssertNil(KeychainService.accessToken)
            XCTAssertNil(self.stormpath.accessToken)
        }
    }
    
    // No data received should not store tokens either
    func testErrorLoginResponseParsing() {
                
        APIService.parseLoginResponseData(nil) { (accessToken, error) -> Void in
            XCTAssertNil(accessToken)
            XCTAssertNil(KeychainService.accessToken)
            XCTAssertNil(self.stormpath.accessToken)
            XCTAssertNotNil(error)
        }
    }
    
    // Test that refreshing access_tokens fails when the refresh token is not set
    func testRefreshAccessTokenWhenRefreshTokenMising() {
        KeychainService.refreshToken = nil
        
        stormpath.apiService.refreshAccessToken() { (accessToken, error) -> Void in
            XCTAssertNil(accessToken)
            XCTAssertNil(KeychainService.accessToken)
            XCTAssertNil(Stormpath.sharedSession.accessToken)
            XCTAssertNotNil(error)
        }
    }

}
