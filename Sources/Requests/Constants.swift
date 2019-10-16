//
//  Constants.swift
//  
//
//  Created by Andrea Sacerdoti on 16.10.2019.
//

import Foundation

let requestProtocol = Bundle.main.infoDictionary?["RequestProtocol"] as? String ?? "https"

/// - Important: This must be set in the app's **Info.plist**.
#if TEST
let baseURL: String = Bundle.main.infoDictionary?["BaseURL"] as? String ?? "test.url.com"
#else
let baseURL = "google.com"
#endif

let authenticationRealm = Bundle.main.infoDictionary?["AuthenticationRealm"] as? String ?? "Restricted"

let defaultProtectionSpace = URLProtectionSpace(host: baseURL, port: 443, protocol: requestProtocol, realm: authenticationRealm, authenticationMethod: NSURLAuthenticationMethodDefault)

let defaultHeaders = [
  "Accept": "application/json",
  "Content-Type": "application/json",
]
