//
//  APIClient.swift
//  Stormpath
//
//  Created by Edward Jiang on 12/2/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

typealias APIRequestCallback = (APIResponse?, NSError?) -> Void

struct APIRequest {
    var headers = [String: String]()
    var body: [String: Any]?
    var contentType = ContentType.json
    var method: APIRequestMethod
    let url: URL
    
    init(method: APIRequestMethod, url: URL) {
        self.method = method
        self.url = url
    }
    
    func send(callback: APIRequestCallback? = nil) {
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set headers
        request.setValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept") // Default to accept json
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
                    let key = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    let value = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    return "\(key)=\(value)"
                }
                    .joined(separator: "&")
                    .data(using: .utf8)
            }
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                let response = response as? HTTPURLResponse else {
                    callback?(nil, error as? NSError)
                return
            }
            var apiResponse = APIResponse(status: response.statusCode)
            apiResponse.headers = response.allHeaderFields as NSDictionary as? [String: String] ?? apiResponse.headers
            apiResponse.body = data
            
            callback?(apiResponse, nil)
        }
        task.resume()
    }
}

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
    var json: [String: Any]? {
        guard contentType == ContentType.json,
        let body = body else {
            return nil
        }
        
        return (try? JSONSerialization.jsonObject(with: body, options: [])) as? [String: Any]
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

enum ContentType: String {
    case urlEncoded = "application/x-www-form-urlencoded",
    json = "application/json"
}

enum APIRequestMethod: String {
    case get = "GET",
    post = "POST",
    put = "PUT",
    delete = "DELETE"
}
