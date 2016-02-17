# Stormpath iOS SDK

[![CI Status](http://img.shields.io/travis/stormpath/stormpath-sdk-swift.svg?style=flat)](https://travis-ci.org/stormpath/stormpath-sdk-swift)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/Stormpath.svg?style=flat)](http://cocoapods.org/pods/Stormpath)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/stormpath/stormpath-sdk-swift)
[![License](https://img.shields.io/cocoapods/l/Stormpath.svg?style=flat)](http://cocoapods.org/pods/Stormpath)
[![Platform](https://img.shields.io/cocoapods/p/Stormpath.svg?style=flat)](http://cocoapods.org/pods/Stormpath)

The iOS Library for [Stormpath](https://stormpath.com/), a framework for authentication & authorization. 

# Requirements

iOS 8.0+ / XCode 7.1+

# Set up

Stormpath iOS SDK currently works only against the [Express-Stormpath](https://github.com/stormpath/express-stormpath) integration. More to come soon!

# Installation

## Cocoapods

Stormpath will be available through [Cocoapods](https://cocoapods.org/), add this line to your `Podfile`:

```ruby
pod "Stormpath"
```

Don't forget to add the use_frameworks! as well:

```ruby
use_frameworks!
```

## Carthage

To use Stormpath iOS SDK with [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "stormpath/stormpath-sdk-swift"
```

## Manually

If you wish to use the framework manually, just download it and drag and drop it in your XCode project or workspace.

# Usage

## 0. Importing the framework

For Swift projects:

```Swift
import Stormpath
```

For Objective-C projects, use the `@import` syntax:

```Objective-C
@import Stormpath;
```

## 1. Setting up

Stormpath's default configuration will attempt to connect to `http://localhost:3000/` as its API server. This is the default configuration for the `express-stormpath` integration and is useful when you're testing against the iOS simulator, but you'll need to set this for any other configurations. Stormpath can read your Info.plist for configuration, but it's easier to modify the `defaultConfiguration` object when making small changes. 

Swift:

```Swift
StormpathConfiguration.defaultConfiguration.APIURL = NSURL(string: "http://localhost:3000")!
```

Objective-C:

```Objective-C
[StormpathConfiguration defaultConfiguration].APIURL = [[NSURL alloc] initWithString:@"http://localhost:3000"];
```

Further examples will be Swift only, Objective-C is the assumed equivalent.

## 2. User registration

In order to register a user, instantiate a `RegistrationModel`. By default, Stormpath Framework integrations will require an `email`, `password`, `givenName`, and `surname`, but this is configurable in the framework integration. Registering a user will not automatically log them in. 

```Swift
let account = RegistrationModel(withEmail: "user@example.com", password: "ExamplePassword")
account.givenName = "Example"
account.surname = "McExample"
```

Then, just invoke the register method on `Stormpath` class:

```Swift
Stormpath.sharedSession.register(account) { (account, error) -> Void in
guard error == nil else {
//The account registration failed
return
}
// Do something with the returned account object, such as save its `href` if needed. 
}
```

## 3. Logging in

To log in, collect the login and password from the user, and then pass them to login method:

```Swift
Stormpath.sharedSession.login(login, password: password) { (success, error) -> Void in
guard error == nil else {
// We could not authenticate the user with the given credentials. Handle the error. 
return
}
// The user is now logged in, and the Stormpath access token will now be set!
}
```

There's no need to save the `acceessToken` anywhere, the SDK automatically stores it into the Keychain and it's accessible as a property on the `Stormpath` class:

```Swift
Stormpath.sharedSession.accessToken
```

Keep this value safe if you're storing it somewhere else.

## 4. Account data

Fetch the account data by using me:

```Swift
Stormpath.sharedSession.me { (account, error) -> Void in
guard let account = account where error == nil else {
// We might not be logged in, the API is misconfigured, the API is down, etc
return
}
// Success! We have the account object.
}
```

## 5. Logout

Logging out is simple:

```Swift
Stormpath.sharedSession.logout()
```

## 6. Password reset

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

## 7. Custom configuration

To be written

## 8. Error handling

To be written

# License

This project is open-source via [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0). See LICENSE file for details.
