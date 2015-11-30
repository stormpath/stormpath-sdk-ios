# Stormpath iOS SDK

[![CI Status](http://img.shields.io/travis/Adis/Stormpath.svg?style=flat)](https://travis-ci.org/Adis/Stormpath)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/Stormpath.svg?style=flat)](http://cocoapods.org/pods/Stormpath)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/stormpath/stormpath-sdk-swift)
[![License](https://img.shields.io/cocoapods/l/Stormpath.svg?style=flat)](http://cocoapods.org/pods/Stormpath)
[![Platform](https://img.shields.io/cocoapods/p/Stormpath.svg?style=flat)](http://cocoapods.org/pods/Stormpath)

**WIP. Dragons be here, unusable at this point.**

iOS Swift library for Stormpath identity API.

https://stormpath.com/

# Requirements

iOS 8.0+ / XCode 7.1+

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

If you wish to use the framework manually, just download it and drag'n'drop it in your XCode project or workspace.

# Usage

## 1. Setting up

To set up the SDK, just point it towards your API endpoint (in your AppDelegate or anywhere before you start the actual usage), like so:

```Swift
Stormpath.setUpWithURL("http://api.stormpath.com")
```

## 2. User registration

In order to register a user, first collect some user data, and put it in a `Dictionary`:

```Swift
let userDictionary = ["username": "User", "email": "user@delete.com", "password": "Password1"]
```

Then, just invoke the register method on `Stormpath` class:

```Swift
Stormpath.register(nil, userDictionary: userDictionary) { (createdUserDictionary, error) -> Void in
            if error == nil {
                // Registration succeeded, createdUserDictionary holds your new user's data
            } else {
                // Something went wrong, check the error to see what
            }
        }
```

## 3. Logging in

To log in, collect the username and password from the user, and then pass them to login method:

```Swift
Stormpath.login(nil, username: self.usernameTextField.text!, password: self.passwordTextField.text!) { (accessToken, error) -> Void in
    if error == nil {
        // accessToken contains the token used for your other API calls
    } else {
        // Error handling goes here
    }
}
```

There's no need to save the `acceessToken` anywhere, the SDK automatically stores it into the Keychain and it's accessible as a property on the `Stormpath` class:

```Swift
Stormpath.accessToken
```

Keep this value safe if you're storing it somewhere else.

## 4. Logout

Logging out is simple:

```Swift
Stormpath.logout({ (error) -> Void in
    SVProgressHUD.dismiss()
    if error == nil {
        // All done
    } else {
        // Something went wrong, but the user is still locally logged out and the tokens are cleared
    }
})
```

## 5. Custom routes

If your API has custom routes, just pass the relative path as a parameter to login, register or others:

```Swift
Stormpath.register("/my/custom/route/to/register", userDictionary: userDictionary) { ... }
```

# License

This project is open-source via [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0). See LICENSE file for details.
