//
//  URLPathServiceTests.swift
//  Stormpath
//
//  Created by Adis on 23/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import XCTest
@testable import Stormpath

class URLPathServiceTests: XCTestCase {
    
    let standardRegisterPath: String = "http://localhost:3000/register"
    let customRegisterPath: String = "http://localhost:3000/my/custom/path/to/register"
    
    let standardLoginPath: String = "http://localhost:3000/oauth/token"
    let customLoginPath: String = "http://localhost:3000/my/custom/path/to/login"
    
    let standardLogoutPath: String = "http://localhost:3000/logout"
    let customLogoutPath: String = "http://localhost:3000/my/custom/path/to/logout"
    
    override func setUp() {
        super.setUp()
        
        Stormpath.setUpWithURL("http://localhost:3000")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: Tests - Register paths
    
    func testStandardRegister() {
        XCTAssertEqual(URLPathService.registerPath(nil), standardRegisterPath)
    }
    
    func testCustomPathRegister() {
        let registerCustomPath = "/my/custom/path/to/register"
        XCTAssertEqual(URLPathService.registerPath(registerCustomPath), customRegisterPath)
    }
    
    func testWeirdInputRegister() {
        XCTAssertEqual(URLPathService.registerPath(""), standardRegisterPath)
        XCTAssertEqual(URLPathService.registerPath("//my/custom/path/to/register//"), customRegisterPath)
    }
    
    // MARK: Tests - Login paths
    
    func testStandardLogin() {
        XCTAssertEqual(URLPathService.loginPath(nil), standardLoginPath)
    }
    
    func testCustomPathLogin() {
        let loginCustomPath = "/my/custom/path/to/login"
        XCTAssertEqual(URLPathService.loginPath(loginCustomPath), customLoginPath)
    }
    
    func testWeirdInputLogin() {
        XCTAssertEqual(URLPathService.loginPath(""), standardLoginPath)
        XCTAssertEqual(URLPathService.loginPath("//my/custom/path/to/login//"), customLoginPath)
    }
    
    // MARK: Tests - Logout paths
    
    func testStandardLogout() {
        XCTAssertEqual(URLPathService.logoutPath(nil), standardLogoutPath)
    }
    
    func testCustomPathLogout() {
        let logoutCustomPath = "/my/custom/path/to/logout"
        XCTAssertEqual(URLPathService.logoutPath(logoutCustomPath), customLogoutPath)
    }
    
    func testWeirdInputLogout() {
        XCTAssertEqual(URLPathService.logoutPath(""), standardLogoutPath)
        XCTAssertEqual(URLPathService.logoutPath("//my/custom/path/to/logout//"), customLogoutPath)
    }
    
}
