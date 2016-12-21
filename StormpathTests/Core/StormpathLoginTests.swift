//
//  StormpathLoginTests.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/18/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import XCTest
@testable import Stormpath

class StormpathLoginTests: XCTestCase {
    var stormpath = Stormpath.sharedSession
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        stormpath.configuration = StormpathConfiguration()
        stormpath.configuration.APIURL = APIURL
        stormpath.logout()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
    }
    
    func testThatWeCanLoginWithAValidUser() {
        let expectation = self.expectation(description: "We should be able to login with a valid user")
        
        stormpath.login(username: testUsername, password: testPassword) { (success, error) -> Void in
            XCTAssertTrue(success, "Login should be successful.")
            XCTAssertNil(error, "Error should be nil, not \(error?.localizedDescription)")
            XCTAssertNotNil(self.stormpath.accessToken, "Access token should not be nil")
            XCTAssertNotNil(self.stormpath.refreshToken, "Refresh token should not be nil")
            
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testThatWeCannotLoginWithAnInvalidUser() {
        let expectation = self.expectation(description: "We shouldn't be able to login with invalid credentials")
        
        stormpath.login(username: "wefiaojef@awfiowjei.com", password: "awoiejfawoeifjawief") { (success, error) -> Void in
            XCTAssertFalse(success, "Login should not be successful")
            XCTAssertNotNil(error, "Error should not be empty")
            XCTAssertEqual(error?.code, 400, "Error should be 400 Bad Request with a json message. Error is \(error?.localizedDescription)")
            
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testThatWeCanRefreshAValidToken() {
        let expectation = self.expectation(description: "We should be able to refresh a token. ")
        
        stormpath.login(username: testUsername, password: testPassword) { (success, error) -> Void in
            XCTAssertTrue(success, "Login should have succeeded. We got error: \(error?.localizedDescription)")
            XCTAssertNil(error, "Error should be nil, not \(error?.localizedDescription)")
            XCTAssertNotNil(self.stormpath.accessToken, "Access token should not be nil")
            XCTAssertNotNil(self.stormpath.refreshToken, "Refresh token should not be nil")
            
            let oldAccessToken = self.stormpath.accessToken
            self.stormpath.refreshAccessToken { (success, error) -> Void in
                XCTAssertTrue(success,"We got an error while refreshing token: \(error?.localizedDescription)")
                XCTAssertNotEqual(oldAccessToken, self.stormpath.accessToken, "The new access token should not equal the old access token")
                
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testThatWeCannotRefreshAInvalidToken() {
        let expectation = self.expectation(description: "We should not be able to refresh a garbage token")
        let garbageToken = "ThisIsInNoWayAValidToken"
        
        stormpath.refreshToken = garbageToken
        
        stormpath.refreshAccessToken { (success, error) -> Void in
            XCTAssertFalse(success, "Refresh should not have succeeded")
            XCTAssertNil(self.stormpath.accessToken, "Access Token should still be nil")
            XCTAssertNotNil(error, "Error object should be set")
            XCTAssertEqual(error?.code, 400, "Error should not be: \(error?.localizedDescription)")
            
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
//    func testThatWeCanLoginWithFacebook() {
//        let expectation = expectationWithDescription("We should be able to login with a valid Facebook access token")
//        let token = "INSERTTOKENHER"
//        
//        stormpath.login(.Facebook, accessToken: token) { (success, error) -> Void in
//            XCTAssertTrue(success, "Login should be successful.")
//            XCTAssertNil(error, "Error should be nil, not \(error?.localizedDescription)")
//            XCTAssertNotNil(self.stormpath.accessToken, "Access token should not be nil")
//            XCTAssertNotNil(self.stormpath.refreshToken, "Refresh token should not be nil")
//            
//            expectation.fulfill()
//        }
//        
//        waitForExpectationsWithTimeout(timeout, handler: nil)
//    }
    
    func testThatWeCannotLoginWithInvalidFacebookToken() {
        let expectation = self.expectation(description: "We should not be able to login with an invalid Facebook access token")
        let token = "GarbageToken"
        
        stormpath.login(socialProvider: .facebook, accessToken: token) { (success, error) -> Void in
            XCTAssertFalse(success, "Login should not be successful")
            XCTAssertNotNil(error, "Error should not be empty")
            XCTAssertEqual(error?.code, 400, "Error should be 400 Bad Request with a json message. Error is \(error?.localizedDescription)")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
