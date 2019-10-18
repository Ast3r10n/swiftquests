//
//  Configuration.swift
//  
//
//  Created by Andrea Sacerdoti on 16.10.2019.
//

import Foundation

open class RequestConfiguration {
  public static var main = RequestConfiguration()

  open var requestProtocol = Bundle.main.infoDictionary?["RequestProtocol"] as? String ?? "https"

  /// - Important: This must be set in the app's **Info.plist**.
  open var baseURL: String = Bundle.main.infoDictionary?["BaseURL"] as? String ?? "test.url.com"

  open var authenticationRealm = Bundle.main.infoDictionary?["AuthenticationRealm"] as? String ?? "Restricted"

  open var defaultProtectionSpace: URLProtectionSpace {
    URLProtectionSpace(host: baseURL, port: 443, protocol: requestProtocol, realm: authenticationRealm, authenticationMethod: NSURLAuthenticationMethodDefault)
  }

  open var defaultHeaders: [String: String] {
    [
      "Accept": "application/json",
      "Content-Type": "application/json",
    ]
  }
}
