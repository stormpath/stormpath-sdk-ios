//
//  APIRequestManager.swift
//  Stormpath
//
//  Created by Edward Jiang on 2/5/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation

class APIRequestManager: NSObject {
    let urlSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
	var request: URLRequest
    
    init(withURL url: URL) {
		request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let version = Bundle(for: APIRequestManager.self).infoDictionary?["CFBundleShortVersionString"] as? String {
            request.setValue("stormpath-sdk-ios/" + version + " iOS/" + UIDevice.current.systemVersion, forHTTPHeaderField: "X-Stormpath-Agent")
        }
    }
    
    func requestDidFinish(_ data: Data, response: HTTPURLResponse) {
        preconditionFailure("Method not implemented")
    }
    
    func performCallback(_ error: NSError?) {
        preconditionFailure("Method not implemented")
    }
    
    func prepareForRequest() {
    }
    
    func begin() {
        prepareForRequest()
        let task = urlSession.dataTask(with: request, completionHandler : requestCompletionHandler)
        task.resume()
    }
    
    func setAccessToken(_ accessToken: String) {
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
    }
    
    private func requestCompletionHandler(_ data: Data?, response: URLResponse?, error: Error?) {
        guard let response = response as? HTTPURLResponse, let data = data, error == nil else {
            if let error = error {
                Logger.logError(error as NSError)
            }
            self.performCallback(error as NSError?)
            return
        }
        
        Logger.logResponse(response, data: data)
        
        //If the status code isn't 2XX
        if response.statusCode / 100 != 2 {
            self.performCallback(StormpathError.errorForResponse(response, data: data))
        } else {
            requestDidFinish(data, response: response)
        }
    }
}
