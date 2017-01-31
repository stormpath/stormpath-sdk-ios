//
//  SocialLoginService.swift
//  Stormpath
//
//  Created by Edward Jiang on 3/4/16.
//  Copyright © 2016 Stormpath. All rights reserved.
//

import Foundation
import SafariServices

/** 
 Social Login Service takes care of aspects of handling deep links intended for social login, as well as routing between different social providers.
*/
class SocialLoginService: NSObject {
    weak var stormpath: Stormpath!
    var queuedcallback: StormpathSuccessCallback?
    
    var safari: UIViewController?
    
    init(withStormpath stormpath: Stormpath) {
        super.init()
        self.stormpath = stormpath
    }
    
    func login(provider: Provider, callback: StormpathSuccessCallback? = nil) {
        stormpath.apiService.loginModel { (loginModel, error) in
            if let loginModel = loginModel {
                if let resolvedProvider = loginModel.accountStores.filter({$0.providerId == provider.asString}).first {
                    self.login(accountStoreHref: resolvedProvider.href, callback: callback)
                } else {
                    callback?(false, StormpathError(code: 400, description: "Could not find a \(provider.asString) directory in the Application's account stores"))
                }
            } else {
                callback?(false, error ?? StormpathError.APIResponseError)
            }
        }
    }
    
    func login(accountStoreHref: URL, callback: StormpathSuccessCallback? = nil) {
        guard urlSchemeIsRegistered() else {
            preconditionFailure("You need to configure your app's Info.plist with your URL scheme (\(stormpath.configuration.urlScheme)) for social login. See https://github.com/stormpath/stormpath-sdk-ios#setting-up-your-xcode-project")
        }
        
        queuedcallback = callback
        
        var authorizeURL = URLComponents(url: stormpath.configuration.APIURL.appendingPathComponent("/authorize"), resolvingAgainstBaseURL: false)!
        authorizeURL.queryItems = [URLQueryItem(name: "response_type", value: "stormpath_token"),
                                        URLQueryItem(name: "account_store_href", value: accountStoreHref.absoluteString),
                                        URLQueryItem(name: "redirect_uri", value: "\(stormpath.configuration.urlScheme)://stormpathCallback")]
        presentOAuthSafariView(authorizeURL.url!)
    }
    
    func handleCallbackURL(_ url: URL) -> Bool {
        safari?.dismiss(animated: true, completion: nil)
        safari = nil
        
        guard url.scheme == stormpath.configuration.urlScheme else {
            return false
        }
        
        guard let stormpathAssertion = url.queryDictionary["jwtResponse"] else {
            queuedcallback = nil
            return false
        }
        
        var request = APIRequest(method: .post, url: stormpath.configuration.APIURL.appendingPathComponent(Endpoints.oauthToken.rawValue))
        request.contentType = .urlEncoded
        request.body = ["grant_type": "stormpath_token",
                        "token": stormpathAssertion]
        
        stormpath.apiService.login(request: request, callback: queuedcallback)
        
        return true
    }
    
    private func presentOAuthSafariView(_ url: URL) {
        if #available(iOS 9, *) {
            safari = SFSafariViewController(url: url)
            
            var topController = UIApplication.shared.keyWindow?.rootViewController
            while let vc = topController?.presentedViewController {
                topController = vc
            }
            topController?.present(safari!, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func urlSchemes() -> [String] {
        guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: AnyObject]] else {
            return [String]()
        }
        
        // Convert the complex dictionary into an array of URL schemes
        return urlTypes.flatMap({($0["CFBundleURLSchemes"] as? [String])?.first })
    }
    
    private func urlSchemeIsRegistered() -> Bool {
        return urlSchemes().contains(stormpath.configuration.urlScheme)
    }
}

/// Social Login Providers
@objc(SPHProvider)
public enum Provider: Int {
    /// Facebook
    case facebook
    
    /// Google
    case google
    
    /// Linkedin
    case linkedin
    
    /// GitHub
    case github
    
    /// Twitter
    case twitter
    
    var asString: String {
        switch self {
        case .facebook:
            return "facebook"
        case .google:
            return "google"
        case .linkedin:
            return "linkedin"
        case .github:
            return "github"
        case .twitter:
            return "twitter"
        }
    }
}

extension URL {
    /// Dictionary with key/value pairs from the URL fragment
    var fragmentDictionary: [String: String] {
        return dictionaryFromFormEncodedString(fragment)
    }
    
    /// Dictionary with key/value pairs from the URL query string
    var queryDictionary: [String: String] {
        return dictionaryFromFormEncodedString(query)
    }
    
    private func dictionaryFromFormEncodedString(_ input: String?) -> [String: String] {
        var result = [String: String]()
        
        guard let input = input else {
            return result
        }
        let inputPairs = input.components(separatedBy: "&")
        
        for pair in inputPairs {
            let split = pair.components(separatedBy: "=")
            if split.count == 2 {
                if let key = split[0].removingPercentEncoding, let value = split[1].removingPercentEncoding {
                    result[key] = value
                }
            }
        }
        return result
    }
}
