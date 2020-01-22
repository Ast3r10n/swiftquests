//
//  RequestConfiguration.swift
//  
//
//  Created by Andrea Sacerdoti on 22/01/2020.
//

import Foundation

public class RequestConfiguration {
  public static var `default` = RequestConfiguration()

  var defaultHeaders: [String: String] =
    [
      "Accept": "application/json",
      "Content-Type": "application/json",
    ]

  var requestProtocol: String = Bundle.main.infoDictionary?["RequestProtocol"] as? String ?? "https"


  /// - Important: This must be set in the app's **Info.plist**.
  var baseURL: String = Bundle.main.infoDictionary?["BaseURL"] as? String ?? "test.url.com"


  var authenticationRealm: String {
    Bundle.main.infoDictionary?["AuthenticationRealm"] as? String ?? "Restricted"
  }

  var defaultProtectionSpace: URLProtectionSpace {
    URLProtectionSpace(host: baseURL,
                       port: 443,
                       protocol: requestProtocol,
                       realm: authenticationRealm,
                       authenticationMethod: NSURLAuthenticationMethodDefault)
  }
}
