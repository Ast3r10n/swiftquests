//
//  RequestConfiguration.swift
//  
//
//  Created by Andrea Sacerdoti on 22/01/2020.
//

import Foundation

open class RequestConfiguration {
  public static var `default` = RequestConfiguration()

  open var defaultHeaders: [String: String] {
    [
      "Accept": "application/json",
      "Content-Type": "application/json",
    ]
  }
  
  open var requestProtocol: String = Bundle.main.infoDictionary?["RequestProtocol"] as? String ?? "https"

  /// - Important: This must be set in the app's **Info.plist**.
  open var baseURL: String = Bundle.main.infoDictionary?["BaseURL"] as? String ?? "test.url.com"


  open var authenticationRealm: String {
    Bundle.main.infoDictionary?["AuthenticationRealm"] as? String ?? "Restricted"
  }

  open var defaultProtectionSpace: URLProtectionSpace {
    URLProtectionSpace(host: baseURL,
                       port: 443,
                       protocol: requestProtocol,
                       realm: authenticationRealm,
                       authenticationMethod: NSURLAuthenticationMethodDefault)
  }
}
