//
//  APIClient.swift
//  Stormpath
//
//  Created by Edward Jiang on 12/2/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import UIKit

typealias APIRequestCallback = (APIResponse?, NSError?) -> Void

class APIClient {
    weak var stormpath: Stormpath?
    let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
    
    init(stormpath: Stormpath? = nil) {
        self.stormpath = stormpath
    }
    
    func execute(request: APIRequest, callback: APIRequestCallback? = nil) {
        var request = request
        var authenticated = false
        
        // If authenticated, add header
        if let accessToken = stormpath?.accessToken {
            request.headers["Authorization"] = "Bearer \(accessToken)"
            authenticated = true
        }
        
        execute(request: request.asURLRequest) { (response, error) in
            // Refresh token & retry request if 401
            if response?.status == 401 && authenticated {
                self.stormpath?.refreshAccessToken { (success, refreshError) in
                    if success {
                        if let accessToken = self.stormpath?.accessToken {
                            request.headers["Authorization"] = "Bearer \(accessToken)"
                            self.execute(request: request.asURLRequest, callback: callback)
                        } else {
                            callback?(response, error)
                        }
                    } else {
                        callback?(nil, error)
                    }
                }
            } else {
                callback?(response, error)
            }
        }
    }
    
    private func execute(request: URLRequest, callback: APIRequestCallback? = nil) {
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                let response = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        callback?(nil, error as? NSError)
                    }
                    return
            }
            var apiResponse = APIResponse(status: response.statusCode)
            apiResponse.headers = response.allHeaderFields as NSDictionary as? [String: String] ?? apiResponse.headers
            apiResponse.body = data
            
            
            DispatchQueue.main.async {
                if response.statusCode / 100 != 2 {
                    callback?(nil, StormpathError.error(from: apiResponse))
                } else {
                    callback?(apiResponse, nil)
                }
            }
        }
        task.resume()
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
