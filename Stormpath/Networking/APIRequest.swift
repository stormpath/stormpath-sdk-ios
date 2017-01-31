//
//  APIRequest.swift
//  Stormpath
//
//  Created by Edward Jiang on 12/15/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

struct APIRequest {
    let url: URL
    var method: APIRequestMethod
    
    var headers = [String: String]()
    var body: [String: Any]?
    var contentType = ContentType.json
    
    init(method: APIRequestMethod, url: URL) {
        self.method = method
        self.url = url
    }
    
    func send(callback: APIRequestCallback? = nil) {
        APIClient().execute(request: self, callback: callback)
    }
    
    var asURLRequest: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set headers
        request.setValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept") // Default to accept json
        
        if let version = Bundle(for: Stormpath.self).infoDictionary?["CFBundleShortVersionString"] as? String {
            request.setValue("stormpath-sdk-ios/" + version + " iOS/" + UIDevice.current.systemVersion, forHTTPHeaderField: "X-Stormpath-Agent")
        }
        
        headers.forEach { (name, value) in
            request.setValue(value, forHTTPHeaderField: name)
        }
        
        // Encode body
        if let body = body {
            request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
            
            switch(contentType) {
            case .json:
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            case .urlEncoded:
                request.httpBody = body.map { (key, value) -> String in
                    var formUrlEncodedCharacters = CharacterSet.urlQueryAllowed
                    formUrlEncodedCharacters.remove(charactersIn: "+&")
                    
                    let key = key.addingPercentEncoding(withAllowedCharacters: formUrlEncodedCharacters) ?? ""
                    let value = "\(value)".addingPercentEncoding(withAllowedCharacters: formUrlEncodedCharacters) ?? ""
                    return "\(key)=\(value)"
                    }
                    .joined(separator: "&")
                    .data(using: .utf8)
            }
        }
        
        return request
    }
}
