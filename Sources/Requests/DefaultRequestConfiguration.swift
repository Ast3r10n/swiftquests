//
//  RequestConfiguration.swift
//  
//
//  Created by Andrea Sacerdoti on 22/01/2020.
//

import Foundation

public protocol RequestConfiguration {
  var defaultHeaders: [String: String] { get set }
  var requestProtocol: String { get set }
  var baseURL: String { get set }
  var authenticationRealm: String { get set }
  var authenticationMethod: String { get set }
  var protectionSpace: URLProtectionSpace { get }
}

public extension RequestConfiguration {
  func assign(to holder: RequestConfigurationHolder = RequestConfigurationHolder.shared) {
    holder.configuration = self
  }
}

open class DefaultRequestConfiguration: RequestConfiguration {

  open var defaultHeaders: [String: String] = [
    "Accept": "application/json",
    "Content-Type": "application/json",
  ]

  open var requestProtocol = Bundle.main.infoDictionary?["RequestProtocol"] as? String ?? "https"

  /// - Important: This must be set in the app's **Info.plist**.
  open var baseURL = Bundle.main.infoDictionary?["BaseURL"] as? String ?? "test.url.com"

  open var authenticationRealm = Bundle.main.infoDictionary?["AuthenticationRealm"] as? String ?? "Restricted"

  open var authenticationMethod = NSURLAuthenticationMethodDefault

  
  public var protectionSpace: URLProtectionSpace {
    URLProtectionSpace(host: baseURL,
                       port: 443,
                       protocol: requestProtocol,
                       realm: authenticationRealm,
                       authenticationMethod: authenticationMethod)
  }
}
