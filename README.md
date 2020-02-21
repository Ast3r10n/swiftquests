# Requests

An object-oriented, URLSession-based network library.

![Swift](https://github.com/Ast3r10n/requests/workflows/Swift/badge.svg) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/Ast3r10n/requests) ![Codecov](https://img.shields.io/codecov/c/github/Ast3r10n/requests?token=44439f4d-d012-4000-a0c1-28647d07b545)

## Installation

Add a Swift Package Dependency to your project with URL:
```
https://github.com/Ast3r10n/requests
```

### Usage

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

# License

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

