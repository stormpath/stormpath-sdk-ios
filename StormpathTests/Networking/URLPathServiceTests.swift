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
    
    let standardRegisterPath: String        = APIURL + "/register"
    let customRegisterPath: String          = APIURL + "/my/custom/path/to/register"
    
    let standardLoginPath: String           = APIURL + "/oauth/token"
    let customLoginPath: String             = APIURL + "/my/custom/path/to/login"
    
    let standardRefreshTokenPath: String    = APIURL + "/logout"
    let customRefreshTokenPath: String      = APIURL + "/my/custom/path/to/logout"
    
    let standardLogoutPath: String          = APIURL + "/logout"
    let customLogoutPath: String            = APIURL + "/my/custom/path/to/logout"
    
    let standardForgotPasswordPath: String  = APIURL + "/forgot"
    let customForgotPasswordPath: String    = APIURL + "/my/custom/path/to/forgot"
    
    override func setUp() {
        super.setUp()
        
        Stormpath.setUpWithURL(APIURL)
    }
    
    override func tearDown() {
        super.tearDown()
        
        Stormpath.APIURL = nil
        KeychainService.accessToken = nil
        KeychainService.refreshToken = nil
    }
    
    // MARK: Tests - Register paths
    
    // These set of methods test the register URL string generation
    
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
    
    // These methods make sure login URL string generation works as intended (these are also refresh token paths)
    
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
    
    // Test that the logout URL string generating works as intended
    
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
    
    // MARK: Tests - Forgot password paths
    
    // Test that the forgot password string for URLs work (these should be same as login URLs)
    
    func testStandardForgotPassword() {
        XCTAssertEqual(URLPathService.passwordResetPath(nil), standardForgotPasswordPath)
    }
    
    func testCustomPathForgotPassword() {
        let forgotPasswordCustomPath = "/my/custom/path/to/forgot"
        XCTAssertEqual(URLPathService.passwordResetPath(forgotPasswordCustomPath), customForgotPasswordPath)
    }
    
    func testWeirdInputForgotPassword() {
        XCTAssertEqual(URLPathService.passwordResetPath(""), standardForgotPasswordPath)
        XCTAssertEqual(URLPathService.passwordResetPath("//my/custom/path/to/forgot//"), customForgotPasswordPath)
    }
    
}
