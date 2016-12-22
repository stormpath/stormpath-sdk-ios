# Stormpath iOS SDK

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Stormpath.svg?style=flat)](http://cocoapods.org/pods/Stormpath)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/stormpath/stormpath-sdk-ios)
[![License](https://img.shields.io/cocoapods/l/Stormpath.svg?style=flat)](http://cocoapods.org/pods/Stormpath)
[![codebeat badge](https://codebeat.co/badges/6b76c7c6-f924-40f6-8ce0-42d165cf6a17)](https://codebeat.co/projects/github-com-stormpath-stormpath-sdk-ios)
[![Slack Status](https://talkstormpath.shipit.xyz/badge.svg)](https://talkstormpath.shipit.xyz)

The iOS SDK for [Stormpath](https://stormpath.com/), a framework for authentication & authorization. 

# Requirements

iOS 8.0+ / Xcode 8.0+ (Swift 3)

# Set up

Stormpath's iOS SDK allows developers utilizing Stormpath to quickly integrate authentication and token management into their apps. 

We're constantly iterating and improving the SDK, so please don't hesitate to send us your feedback! You can reach us via support@stormpath.com, or on the issue tracker for feature requests. 

# Installation

## CocoaPods

Stormpath is available through [CocoaPods](https://cocoapods.org/). Add this line to your `Podfile` to begin:

```ruby
pod 'Stormpath', '~> 3.0'
```

## Carthage

To use Stormpath with [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "stormpath/stormpath-sdk-ios" ~> 3.0
```

# Usage

To see the SDK in action, you can try downloading the [Stormpath iOS Example](https://github.com/stormpath/stormpath-ios-example) project. We've built the same app twice, once in Objective-C and another time in Swift so you can see how to use the SDK. 

## Importing the framework

For Swift projects:

```Swift
import Stormpath
```

For Objective-C projects: 

```Objective-C
#import "Stormpath-Swift.h"
```

## Configuring Stormpath

The iOS SDK (v3) leverages the [Stormpath Client API](https://docs.stormpath.com/client-api/product-guide/latest/index.html) for its authentication needs. You'll need to sign into the [Stormpath Admin Console](https://api.stormpath.com/) to get your Client API details. Go into your Application > Policies > Client API, and ensure that it's enabled. Copy your Client API URL, and set it in your Xcode project: 

Swift:

```Swift
Stormpath.sharedSession.configuration.APIURL = URL(string: "https://edjiang.apps.stormpath.io")!
```

Objective-C:

```Objective-C
[[SPHStormpath sharedSession] configuration].APIURL = [[NSURL alloc] initWithString:@"https://edjiang.apps.stormpath.io"];
```

## User registration

In order to register a user, instantiate a `RegistrationForm` object. Stormpath requires an `email` and `password` to register.

```Swift
let newUser = RegistrationForm(email: "user@example.com", password: "ExamplePassword")
```

Then, just invoke the register method on `Stormpath` class:

```Swift
Stormpath.sharedSession.register(account: newUser) { (account, error) -> Void in
    guard let account = account where error == nil else {
        //The account registration failed
        return
    }
    // Do something with the returned account object, such as save its `href` if needed. 
    // Registering a user will not automatically log them in. 
}
```

*Note: Stormpath callbacks always happen on the main thread, so you can make UI changes directly in the callback.*

## Logging in

To log in, collect the email (or username) and password from the user, and then pass them to the login method:

```Swift
Stormpath.sharedSession.login(username: "user@example.com", password: "ExamplePassword") { success, error in
    guard error == nil else {
        // We could not authenticate the user with the given credentials. Handle the error. 
        return
    }
    // The user is now logged in, and you can use the Stormpath access token to make API requests!
}
```

## Logging in with Social Providers

Stormpath also supports logging in with a variety of social providers Facebook, Google, LinkedIn, GitHub, and more. There are two flows for enabling this:

1. Let Stormpath handle the social login.
2. Use the social provider's iOS SDK to get an access token, and pass it to Stormpath to log in.

We've made it extremely easy to set up social login without using the social provider SDKs, but if you need to use their SDKs for more features besides logging in, you should use flow #2 (and skip directly to [Using a social provider SDK](#using-a-social-provider-sdk)). 

### Configure Your Social Directory in Stormpath

To set up your social directory, read more about [social login in the Stormpath Client API Guide](https://docs.stormpath.com/client-api/product-guide/latest/social_login.html#before-you-start).

### Setting up your Xcode project

In your Xcode project, you'll need to create a URL Scheme so that the login process can call back to your app. Go to the project's info tab. Under "URL Types", add a new entry, and in the URL schemes form field, type in your Client API's DNS label, but reversed. For instance, if your Client API DNS Label is `edjiang.apps.stormpath.io`, type in `io.stormpath.apps.edjiang`. 

In the [Stormpath Admin Console](https://api.stormpath.com)'s Application settings, add that URL as an "authorized callback URL", appending `://stormpathCallback`. Following my earlier example, I would use `io.stormpath.apps.edjiang`. 

Also, add the following methods to your `AppDelegate` in your Xcode project:

```Swift
// iOS 9+ link handler
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
    return Stormpath.sharedSession.application(app, open: url, options: options)
}

// iOS 8 and below link handler. Needed if you want to support older iOS
func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    return Stormpath.sharedSession.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
}
```

### Initiating Social Login

Now, you can initiate the login screen by calling: 

```Swift
Stormpath.sharedSession.login(provider: .facebook) { (success, error) -> Void in
    // This callback is the same as the regular Stormpath.login callback. 
    // If the user cancels the login, the login was never started, and
    // this callback will not be called.
}
```

### Using a Social Provider SDK

If you're using the [Facebook SDK](https://developers.facebook.com/docs/facebook-login/ios) or [Google SDK](https://developers.google.com/identity/sign-in/ios/) for your app, follow their setup instructions instead. Once you successfully sign in with their SDK, utilize the following methods to send your access token to Stormpath, and log in your user: 

```Swift
Stormpath.sharedSession.login(provider: .facebook, accessToken: FBSDKAccessToken.currentAccessToken().tokenString) { (success, error) -> Void in
	// Same callback as above
}

Stormpath.sharedSession.login(provider: .google, accessToken: GIDSignIn.sharedInstance().currentUser.authentication.accessToken) { (success, error) -> Void in
	// Same callback as above
}
```

## Using the Access Token

You can utilize the access token to access any of your API endpoints that require authentication. It's stored as a property on the Stormpath object as `Stormpath.sharedSession.accessToken`. If you need to refresh it, use `Stormpath.sharedSession.refreshAccessToken()`. Depending on the networking library you're using, here's how you'd use the access token:

### NSURLSession

```Swift
var request = URLRequest(URL: url)
request.setValue("Bearer " + accessToken ?? "", forHTTPHeaderField: "Authorization")
```

### Alamofire

```Swift
let headers = ["Authorization": "Bearer " + accessToken ?? ""]
Alamofire.request(url, method: .get, headers: headers)
```

*Note: As of the iOS 9 SDK, Apple has enabled App Transport Security by default. If you're developing against an `http` endpoint, you'll need to disable it. For production, you should always be using `https` for your API endpoints.*

## Account data

Stormpath's framework integrations provide a default endpoint for retrieving profile information. Fetch the account data by using me:

```Swift
Stormpath.sharedSession.me { account, error in
	guard let account = account where error == nil else {
	    // We might not be logged in, the API is misconfigured, the API is down, etc
	    return
	}
	// Success! We have the account object.
}
```

## Logout

Logging out is simple. This will delete the access token and refresh token from the user's device, and make an API request to delete from the server. 

```Swift
Stormpath.sharedSession.logout()
```

## Password reset

To reset a user's password, you'll need to collect their email first. Then simply pass that email to the `resetPassword` function like so:

```Swift
Stormpath.sharedSession.resetPassword(email: "user@example.com") { success, error in
    guard error == nil else {
    	// A network or API problem occurred. 
        return
    }
    // We succeeded in making the API request. 
}
```

## Error handling

When using Stormpath, you can encounter errors for several reasons: 

1. Network errors - the network request failed for some reason. 
2. User errors - errors because of user input, ex: "invalid username or password".
3. API errors - the API is misconfigured, or returning an unrecognized response. 

If there's a network error, Stormpath will return the `NSError` associated with `NSURLSession` to your code. Otherwise, Stormpath will return `StormpathError`, a `NSError` subclass. 

For user errors, `StormpathError` will have the HTTP error code of the API response (usually 400), and `localizedDescription` set to a user-readable error message which is safe to display to the user. 

In special cases, StormpathError will have code 0 or 1. These are developer errors that should not be displayed to the user. 0 stands for "Stormpath SDK Error", and most likely indicates a bug with the Stormpath SDK that should be reported to us. 1 stands for "API Response Error", and means that the API responded with something unexpected. This most likely means that you have your backend integration misconfigured. 

## Configuring Stormpath with Info.plist

`StormpathConfiguration` can be used to point Stormpath to a specific API URL. While you can modify the object directly, you can also put your configuration in Info.plist. To add the Stormpath configuration, right click on Info.plist, and click "open as source code". Before the last `</plist>` tag, paste: 

```xml
<key>Stormpath</key>
<dict>
	<key>APIURL</key>
	<string>http://localhost:3000</string>
</dict>
```

You can modify any of these values, and `StormpathConfiguration` will load these on first initialization. 

## Handling Multiple Sessions

Stormpath can be used to store multiple user accounts, even against multiple API servers using Stormpath. This is useful if you're making a multi-tenant application that allows the user to be logged in under different accounts at the same time. 

To use this feature, instead of using `Stormpath.sharedSession`, initialize Stormpath with a custom identifier:

```Swift
Stormpath(identifier: "newSession")
```

This will create an instance of Stormpath with the default configuration (shared with the rest of the app) that will store `accessTokens` and `refreshTokens` in its own partition in the iOS Keychain. 

This identifier can be used in your app to identify a user session contained in Stormpath, and properly restore it in between app opens. 

*Note: the identifier for `Stormpath.sharedSession` is "default", so do not use this as an identifier for another instance of Stormpath.*

# License

This project is open-source via [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0). See the LICENSE file for details.
