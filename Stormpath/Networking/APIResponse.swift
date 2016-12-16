//
//  APIResponse.swift
//  Stormpath
//
//  Created by Edward Jiang on 12/15/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

struct APIResponse {
    var status: Int
    
    var headers = [String: String]()
    var body: Data?
    
    var contentType: ContentType? {
        let contentTypeHeader = headers.filter {
            $0.key.lowercased() == "content-type"
            }.first?.value.components(separatedBy: ";").first ?? ""
        
        return ContentType(rawValue: contentTypeHeader)
    }
    var json: JSON {
        guard contentType == ContentType.json,
            let body = body else {
                return JSON.null
        }
        
        return JSON(data: body)
    }
    
    var formUrlencoded: [String: String]? {
        guard contentType == ContentType.urlEncoded else {
            return nil
        }
        
        // TODO; we don't really use formurlencoded responses
        preconditionFailure("Not implemented")
    }
    
    init(status: Int) {
        self.status = status
    }
}
