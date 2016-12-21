//
//  StormpathRegistrationTests.swift
//  Stormpath
//
//  Created by Adis on 21/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import XCTest
@testable import Stormpath

class StormpathRegistrationTests: XCTestCase {
    var randomId = arc4random_uniform(10000000)
    var stormpath = Stormpath.sharedSession
    var accountInfo: RegistrationForm!
    
    override func setUp() {
        super.setUp()
        randomId = arc4random_uniform(10000000)
        
        accountInfo = RegistrationForm(email: "sp_\(randomId)@example.com", password: "TestTest1")
        accountInfo.givenName = "FN\(randomId)"
        accountInfo.surname = "Stormtrooper"
        
        stormpath.configuration = StormpathConfiguration()
        stormpath.configuration.APIURL = APIURL
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testThatStormpathCanRegisterWithValidData() {
        let expectation = self.expectation(description: "We can register for an account.")
    
        stormpath.register(account: accountInfo) { (account, error) -> Void in
            XCTAssertNotNil(account, "Account should not be nil")
            XCTAssertNil(error, "Error should not be \(error?.localizedDescription)")
            
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testThatRegistrationResultsMatchRegistrationValues() {
        let expectation = self.expectation(description: "The user data returned should match what we registered.")
        
        stormpath.register(account: accountInfo) { (account, error) -> Void in
            guard let account = account else {
                XCTFail("No account was returned")
                return
            }
            XCTAssertEqual(self.accountInfo.email, account.email)
            XCTAssertEqual(self.accountInfo.givenName, account.givenName)
            XCTAssertEqual(self.accountInfo.surname, account.surname)
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testThatWeCannotRegisterWithInvalidEmail() {
        let expectation = self.expectation(description: "We cannot register for an account with an invalid email.")
        accountInfo.email = "asdf"
        
        stormpath.register(account: accountInfo) { (account, error) -> Void in
            XCTAssertNil(account, "Account should not be created or returned")
            XCTAssertNotNil(error, "Error should have occurred")
            
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testThatRegistrationReturnsErrorWithCorrectFormat() {
        let expectation = self.expectation(description: "We should have a 400 error with a message")
        accountInfo.email = "asdf"
        
        stormpath.register(account: accountInfo) { (account, error) -> Void in
            guard let error = error else {
                XCTFail("Account creation did not return an error")
                return
            }
            XCTAssertEqual(error.code, 400, "Error should have been 400 with a message, not: \(error.localizedDescription)")

            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testThatStormpathCannotRegisterWithExtraFields() {
        let expectation = self.expectation(description: "We cannot pass arbitrary fields to the registration API")
        accountInfo.customFields["notAConfiguredParameter"] = "RandomData"
        
        stormpath.register(account: accountInfo) { (account, error) -> Void in
            guard let error = error else {
                XCTFail("Account creation did not return an error")
                return
            }
            XCTAssertEqual(error.code, 400, "Error should have been 400 with a message, not: \(error.localizedDescription)")
            
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
