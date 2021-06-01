# SwiftQuests

An object-oriented, URLSession-based network library.

![Swift](https://github.com/Ast3r10n/requests/workflows/Swift/badge.svg) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/Ast3r10n/requests) ![Codecov](https://img.shields.io/codecov/c/gh/Ast3r10n/swiftquests?token=9980b291f6634fe6a969036234755d8c) ![License](https://img.shields.io/github/license/Ast3r10n/swiftquests) ![Cocoapods](https://img.shields.io/cocoapods/p/SwiftQuests) ![LastCommit](https://img.shields.io/github/last-commit/Ast3r10n/swiftquests)

## Installation

### Swift Package Manager

Add a Swift Package Dependency to your project with URL:
```
https://github.com/Ast3r10n/swiftquests
```

### Cocoapods

Add `SwiftQuests` to your Podfile:
```ruby
pod 'SwiftQuests'
```

## Usage

A `Request` is a basic, standalone object, with a single associated task, configured through its initialiser.
Once initialised, a `Request` is (for the most part) immutable. Its task will only launch through the `perform` method call.

### Basic Request

To perform a basic `Request`, initialise one:

```swift
do {
  let request = try Request(.get,
                            atPath: "/user")
} catch {
  // Error handling
}
```
You then call the `perform` method to launch its associated task.

```swift
do {
  try request.perform { result in
    // Response implementation
  }
} catch {
  // Error handling
}
```

### Decodable object Request

`Request`s support automatic JSON decoding using `Decodable` objects 

Here's an example `Request` to get a `Decodable` `User` object from the `/user` endpoint.

```swift
do {
  try Request(.get,
              atPath: "/user")
    .perform(decoding: User.self) { result in
    
    // Your completion handler here
  }
} catch {
  // Error handling
}
```
