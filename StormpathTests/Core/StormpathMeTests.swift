//
//  StormpathMeTests.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/19/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import XCTest
@testable import Stormpath

class StormpathMeTests: XCTestCase {
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
    
    func testThatWeCanRetrieveAccount() {
        let expectation = self.expectation(description: "We should be able to get an account object from the server.")
        
        stormpath.login(username: testUsername, password: testPassword) { (success, error) -> Void in
            XCTAssertTrue(success, "Login should be a success. ")
            self.stormpath.me { (account, error) -> Void in
                XCTAssertNotNil(account, "Account should not be nil; error is \(error?.localizedDescription)")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testThatWeCannotRetrieveAccountWithoutAccessToken() {
        let expectation = self.expectation(description: "We should not be able to retrieve the account without an access token.")
        
        stormpath.me { (account, error) -> Void in
            XCTAssertNil(account, "Account should be nil")
            XCTAssertEqual(error?.code, 401, "Error should be 401 unauthorized, error is: \(error?.localizedDescription)")
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testThatWeCanResetPasswordWithArbitraryEmail() {
        let expectation = self.expectation(description: "We can always make a successful request to reset the password")
        
        stormpath.resetPassword(email: "fakeuser@example.com") { (success, error) -> Void in
            XCTAssertTrue(success, "Success should be true")
            XCTAssertNil(error, "There should be no error unless there's a network issue")
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
}
