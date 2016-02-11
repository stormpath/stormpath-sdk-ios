//
//  StormpathError.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/9/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

let StormpathErrorDomain = "StormpathErrorDomain"

/*
Errors:
OAuthInvalidRequest
OAuthInvalidClient
OAuthUnauthorizedClient
OAuthInvalidGrant
OAuthUnsupportedGrantType
OAuthInvalidScope
*/

public class StormpathError: NSError {
    
}

public enum StormpathErrorCodes: Int {
    case Placeholder = 0
}