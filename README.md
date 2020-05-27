# SwiftQuests

An object-oriented, URLSession-based network library.

![Swift](https://github.com/Ast3r10n/requests/workflows/Swift/badge.svg) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/Ast3r10n/requests) ![Codecov](https://img.shields.io/codecov/c/gh/Ast3r10n/swiftquests?token=43bbf53852d24e549074f62b39f01e39)

## Installation

### Swift Package Manager

Add a Swift Package Dependency to your project with URL:
```
https://github.com/Ast3r10n/swiftquests
```

### Cocoapods

Add `SwiftQuests` to your Podfile:
```
pod 'SwiftQuests'
```

## Usage

A `Request` is a basic, standalone object, with a single associated task, configured through its initialiser.
Once initialised, a `Request` is (for the most part) immutable. Its task will only launch through the `perform` method call.

### Basic Request

To perform a basic `Request`, initialise one:

```
do {
  let request = try Request(.get,
                            atPath: "/user")
} catch {
  // Error handling
}
```
You then call the `perform` method to launch its associated task.

```
do {
  try request.perform { data, response, error in
    // Response implementation
  }
} catch {
  // Error handling
}
```

### Decodable object Request

`Request`s support automatic JSON decoding using `Decodable` objects 

Here's an example `Request` to get a `Decodable` `User` object from the `/user` endpoint.

```
do {
  try Request(.get,
              atPath: "/user")
    .perform(decoding: User.self) { user, response, error in
    
    // Your completion handler here
  }
} catch {
  // Error handling
}
```
