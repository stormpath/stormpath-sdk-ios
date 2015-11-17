//
//  Stormpath.swift
//  Stormpath
//
//  Created by Adis on 16/11/15.
//  Copyright © 2015 Stormpath. All rights reserved.
//

import UIKit

class Stormpath: NSObject {
    
    // MARK: Initial setup
    
    class var APIKey: String {
        get {
            return ""
        }
        
        set {
            
        }
    }
    
    class var secret: String {
        get {
            return ""
        }
        
        set {
            
        }
    }
    
    // MARK: Basic user management
    
    func register(username: String, password: String, completion: (error: NSError) -> Void) {
        
    }
    
    func login(username: String, password: String, completion: (error: NSError) -> Void) {
        
    }
    
    func logout(completion: (error: NSError) -> Void) {
        
    }
    
    func resetPassword() {
        
    }
    
    // MARK: Token handling
    
    func accessToken() -> String {
        return ""
    }
    
    func refreshAccesToken() {
        
    }

}
