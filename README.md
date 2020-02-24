# Requests

An object-oriented, URLSession-based network library.

![Swift](https://github.com/Ast3r10n/requests/workflows/Swift/badge.svg) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/Ast3r10n/requests) ![Codecov](https://img.shields.io/codecov/c/gh/Ast3r10n/Requests?token=43bbf53852d24e549074f62b39f01e39)

## Installation

Add a Swift Package Dependency to your project with URL:
```
https://github.com/Ast3r10n/requests
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

## License

Copyright 2020 Andrea Sacerdoti

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
