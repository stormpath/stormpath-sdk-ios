# Stormpath iOS SDK

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Stormpath.svg?style=flat)](http://cocoapods.org/pods/Stormpath)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/stormpath/stormpath-sdk-ios)
[![License](https://img.shields.io/cocoapods/l/Stormpath.svg?style=flat)](http://cocoapods.org/pods/Stormpath)
[![codebeat badge](https://codebeat.co/badges/0038aa1f-d481-4ad0-a244-3a6d803c3dbe)](https://codebeat.co/projects/github-com-stormpath-stormpath-sdk-ios)

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
pod 'Stormpath', '~> 1.2'
```

Don't forget to uncomment use_frameworks! as well:

```ruby
use_frameworks!
```

## Carthage

To use Stormpath with [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "stormpath/stormpath-sdk-ios" ~> 1.2
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

## Setting up the API Endpoints

Stormpath's default configuration will attempt to connect to `http://localhost:3000/`. This is the default configuration for the `express-stormpath` integration and is useful when you're testing in the iOS simulator. However, you'll need to modify this for any other setups. 

Swift:

```Swift
StormpathConfiguration.defaultConfiguration.APIURL = NSURL(string: "http://localhost:3000")!
```

Objective-C:

```Objective-C
[StormpathConfiguration defaultConfiguration].APIURL = [[NSURL alloc] initWithString:@"http://localhost:3000"];
```

*Note: As of the iOS 9 SDK, Apple has enabled App Transport Security by default. If you're developing against an `http` endpoint, you'll need to disable it. For production, you should always be using `https` for your API endpoints.*

## User registration

In order to register a user, instantiate a `RegistrationModel` object. By default, Stormpath framework integrations require an `email`, `password`, `givenName`, and `surname`. 

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
    // Registering a user will not automatically log them in. 
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
    // The user is now logged in, and you can use the Stormpath access token to make API requests!
}
```

## Logging in with Facebook or Google

Stormpath also supports logging in with Facebook or Google. There are two flows for enabling this:

1. Let Stormpath handle the Facebook / Google Login.
2. Use the Facebook / Google iOS SDK to get an access token, and pass it to Stormpath to log in.

We've made it extremely easy to set up social login without using the Facebook / Google SDK, but if you need to use their SDKs for more features besides logging in, you should use flow #2 (and skip directly to "Advanced ____ Login"). 

### Setting up your AppDelegate

In your Xcode project, add the following methods to your `AppDelegate`:

```Swift
// Only needed for iOS 9
func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    return Stormpath.sharedSession.application(app, openURL: url, options: options)
}
    
func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    return Stormpath.sharedSession.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
}
```

### Setting up Facebook Login

To get started, you first need to [register an application](https://developers.facebook.com/?advanced_app_create=true) with Facebook. After registering your app, go into your app dashboard's settings page. Click "Add Platform", and fill in your Bundle ID, and turn "Single Sign On" on. 

Then, [sign into Stormpath](https://api.stormpath.com/login) and add a Facebook directory to your account. Fill the App ID and Secret with the values given to you in the Facebook app dashboard. Then, add the directory to your Stormpath application. 

Finally, open up your App's Xcode project and go to the project's info tab. Under "URL Types", add a new entry, and in the URL schemes form field, type in `fb[APP_ID_HERE]`, replacing `[APP_ID_HERE]` with your Facebook App ID. 

Then, you can initiate the login screen by calling: 

```Swift
Stormpath.sharedSession.login(socialProvider: .Facebook) { (success, error) -> Void in
    // This callback is the same as the regular Stormpath.login callback. 
    // If the user cancels the login, the login was never started, and
    // this callback will not be called.
}
```

### Setting up Google Login

To get started, you first need to [register an application](https://console.developers.google.com/project) with Google. Click "Enable and Manage APIs", and then the credentials tab. Create two sets of OAuth Client IDs, one as "Web Application", and one as "iOS". 

Then, [sign into Stormpath](https://api.stormpath.com/login) and add a Google directory to your account. Fill in the Client ID and Secret with the values given to you for the web client. (You can fill in "Google Authorized Redirect URI" with `http://YOURSERVER/callbacks/google`. Then, add the directory to your Stormpath application. 

Finally, open up your App's Xcode project and go to the project's info tab. Under "URL Types", add a new entry, and in the URL schemes form field, type in your Google iOS Client's `iOS URL scheme` from the Google Developer Console. 

Then, you can initiate the login screen by calling: 

```Swift
Stormpath.sharedSession.login(socialProvider: .Google) { (success, error) -> Void in
	// Same callback as above
}
```

### Using the Google or Facebook SDK

If you're using the [Facebook SDK](https://developers.facebook.com/docs/facebook-login/ios) or [Google SDK](https://developers.google.com/identity/sign-in/ios/) for your app, follow their setup instructions instead. Once you successfully sign in with their SDK, utilize the following methods to send your access token to Stormpath, and log in your user: 

```Swift
Stormpath.sharedSession.login(socialProvider: .Facebook, accessToken: FBSDKAccessToken.currentAccessToken().tokenString) { (success, error) -> Void in
	// Same callback as above
}

Stormpath.sharedSession.login(socialProvider: .Google, accessToken: GIDSignIn.sharedInstance().currentUser.authentication.accessToken) { (success, error) -> Void in
	// Same callback as above
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
