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
        XCTAssertEqual(URLPath.Register.path(nil), standardRegisterPath)
    }
    
    func testCustomPathRegister() {
        let registerCustomPath = "/my/custom/path/to/register"
        XCTAssertEqual(URLPath.Register.path(registerCustomPath), customRegisterPath)
    }
    
    func testWeirdInputRegister() {
        XCTAssertEqual(URLPath.Register.path(""), standardRegisterPath)
        XCTAssertEqual(URLPath.Register.path("//my/custom/path/to/register//"), customRegisterPath)
    }
    
    // MARK: Tests - Login paths
    
    // These methods make sure login URL string generation works as intended (these are also refresh token paths)
    
    func testStandardOAuth() {
        XCTAssertEqual(URLPath.OAuth.path(nil), standardLoginPath)
    }
    
    func testCustomPathOAuth() {
        let loginCustomPath = "/my/custom/path/to/login"
        XCTAssertEqual(URLPath.OAuth.path(loginCustomPath), customLoginPath)
    }
    
    func testWeirdInputOAuth() {
        XCTAssertEqual(URLPath.OAuth.path(""), standardLoginPath)
        XCTAssertEqual(URLPath.OAuth.path("//my/custom/path/to/login//"), customLoginPath)
    }
    
    // MARK: Tests - Logout paths
    
    // Test that the logout URL string generating works as intended
    
    func testStandardLogout() {
        XCTAssertEqual(URLPath.Logout.path(nil), standardLogoutPath)
    }
    
    func testCustomPathLogout() {
        let logoutCustomPath = "/my/custom/path/to/logout"
        XCTAssertEqual(URLPath.Logout.path(logoutCustomPath), customLogoutPath)
    }
    
    func testWeirdInputLogout() {
        XCTAssertEqual(URLPath.Logout.path(""), standardLogoutPath)
        XCTAssertEqual(URLPath.Logout.path("//my/custom/path/to/logout//"), customLogoutPath)
    }
    
    // MARK: Tests - Forgot password paths
    
    // Test that the forgot password string for URLs work (these should be same as login URLs)
    
    func testStandardForgotPassword() {
        XCTAssertEqual(URLPath.PasswordReset.path(nil), standardForgotPasswordPath)
    }
    
    func testCustomPathForgotPassword() {
        let forgotPasswordCustomPath = "/my/custom/path/to/forgot"
        XCTAssertEqual(URLPath.PasswordReset.path(forgotPasswordCustomPath), customForgotPasswordPath)
    }
    
    func testWeirdInputForgotPassword() {
        XCTAssertEqual(URLPath.PasswordReset.path(""), standardForgotPasswordPath)
        XCTAssertEqual(URLPath.PasswordReset.path("//my/custom/path/to/forgot//"), customForgotPasswordPath)
    }
    
}
