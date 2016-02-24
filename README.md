# Stormpath iOS SDK

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Stormpath.svg?style=flat)](http://cocoapods.org/pods/Stormpath)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/stormpath/stormpath-sdk-swift)
[![License](https://img.shields.io/cocoapods/l/Stormpath.svg?style=flat)](http://cocoapods.org/pods/Stormpath)
[![codebeat badge](https://codebeat.co/badges/0038aa1f-d481-4ad0-a244-3a6d803c3dbe)](https://codebeat.co/projects/github-com-stormpath-stormpath-sdk-swift)

The iOS Library for [Stormpath](https://stormpath.com/), a framework for authentication & authorization. 

# Requirements

iOS 8.0+ / Xcode 7.1+

# Set up

Stormpath's iOS SDK allows developers utilizing Stormpath to quickly integrate authentication and token management into their app. 

This SDK will not send direct requests to Stormpath, and instead assumes that you'll have a backend that conforms to the [Stormpath Framework Spec](https://github.com/stormpath/stormpath-framework-spec). With one of these backends, you'll be able to configure Stormpath so it fits your needs. 

We're constantly iterating and improving the SDK, so please don't hesitate to send us your feedback! You can reach us via support@stormpath.com, or on the issue tracker for feature requests. 

## Setting up a Compatible Backend

Stormpath's framework integrations plug into popular web frameworks and expose pre-built API endpoints that you can customize. The two backends that are currently compatible with the iOS SDK are: [express-stormpath](https://github.com/stormpath/express-stormpath) (v3.0) and [stormpath-laravel](https://github.com/stormpath/stormpath-laravel) (v0.3).

If you're just testing, it's pretty quick to set up a server using the [express sample project](https://github.com/stormpath/express-stormpath-sample-project). 

# Installation

## CocoaPods

Stormpath is available through [CocoaPods](https://cocoapods.org/). Add this line to your `Podfile` to begin:

```ruby
pod "Stormpath" ~> 1.1
```

Don't forget to uncomment use_frameworks! as well:

```ruby
use_frameworks!
```

## Carthage

To use Stormpath with [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "stormpath/stormpath-sdk-swift" ~> 1.1
```

## Manually

If you wish to use the framework manually, just download it and drag and drop it in your Xcode project or workspace.

# Usage

## Importing the framework

For Swift projects:

```Swift
import Stormpath
```

For Objective-C projects: 

```Objective-C
#import "Stormpath-Swift.h"
```

## Setting up the API Endpoints

Stormpath's default configuration will attempt to connect to `http://localhost:3000/`. This is the default configuration for the `express-stormpath` integration and is useful when you're testing in the iOS simulator. However, you'll need to modify this for any other configurations. 

Swift:

```Swift
StormpathConfiguration.defaultConfiguration.APIURL = NSURL(string: "http://localhost:3000")!
```

Objective-C:

```Objective-C
[StormpathConfiguration defaultConfiguration].APIURL = [[NSURL alloc] initWithString:@"http://localhost:3000"];
```

*Note: As of the iOS 9 SDK, Apple has enabled App Transport Security by default. If you're developing against an `http` endpoint, you'll need to disable it. For production, you should *always* be using `https` for your API endpoints.*

## User registration

In order to register a user, instantiate a `RegistrationModel`. By default, Stormpath Framework integrations will require an `email`, `password`, `givenName`, and `surname`, but this is configurable in the framework integration. Registering a user will not automatically log them in. 

```Swift
let account = RegistrationModel(email: "user@example.com", password: "ExamplePassword")
account.givenName = "Example"
account.surname = "McExample"
```

Then, just invoke the register method on `Stormpath` class:

```Swift
Stormpath.sharedSession.register(account) { (account, error) -> Void in
    guard let account = account where error == nil else {
        //The account registration failed
        return
    }
    // Do something with the returned account object, such as save its `href` if needed. 
}
```

*Note: Stormpath callbacks always happen on the main thread, so you can make UI changes directly in the callback.*

## Logging in

To log in, collect the email (or username) and password from the user, and then pass them to the login method:

```Swift
Stormpath.sharedSession.login("user@example.com", password: "ExamplePassword") { (success, error) -> Void in
    guard error == nil else {
        // We could not authenticate the user with the given credentials. Handle the error. 
        return
    }
    // The user is now logged in, and the Stormpath access token will now be set!
}
```

## Using the Access Token

You can utilize the access token to access any of your API endpoints that require authentication. It's stored as a property on the Stormpath object as `Stormpath.sharedSession.accessToken`. If you need to refresh it, use `Stormpath.sharedSession.refreshAccessToken()`. Depending on the networking library you're using, here's how you'd use the access token:

### NSURLSession

```Swift
let request = NSMutableURLRequest(URL: url)
request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
```

### Alamofire

```Swift
let headers = ["Authorization": "Bearer " + accessToken]
Alamofire.request(.GET, url, headers: headers)
```

## Account data

Stormpath's framework integrations provide a default endpoint for retrieving profile information. Fetch the account data by using me:

```Swift
Stormpath.sharedSession.me { (account, error) -> Void in
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
Stormpath.sharedSession.resetPassword("user@example.com") { (success, error) -> Void in
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

## Custom configuration

`StormpathConfiguration` can be used to point Stormpath to a specific API URL, as well as custom endpoints. While you can modify the object directly, you can also put your configuration in Info.plist. To add the Stormpath configuration, right click on Info.plist, and click "open as source code". Before the last `</plist>` tag, paste: 

```xml
<key>Stormpath</key>
<dict>
	<key>APIURL</key>
	<string>http://localhost:3000</string>
	<key>customEndpoints</key>
	<dict>
		<key>me</key>
		<string>/me</string>
		<key>verifyEmail</key>
		<string>/verify</string>
		<key>forgotPassword</key>
		<string>/forgot</string>
		<key>oauth</key>
		<string>/oauth/token</string>
		<key>logout</key>
		<string>/logout</string>
		<key>register</key>
		<string>/register</string>
	</dict>
</dict>
```

You can modify any of these values, and StormpathConfiguration will load these on first initialization. 

## Handling Multiple Sessions

Stormpath can be used to store multiple user accounts, even against multiple API servers using Stormpath. This is useful if you're making a multi-tenant application that allows the user to be logged in under different accounts at the same time. 

To use this feature, instead of using `Stormpath.sharedSession`, initialize Stormpath with a custom identifier:

```Swift
Stormpath(withIdentifier: "newSession")

# License

This project is open-source via [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0). See LICENSE file for details.
