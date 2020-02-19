//
//  DefaultRequestConfiguration.swift
//  
//
//  Created by Andrea Sacerdoti on 22/01/2020.
//

import Foundation

public protocol RequestConfiguration {
  /// The default Request headers.
  ///
  /// Any headers passed to specific `Requests` would be appended to these.
  var defaultHeaders: [String: String] { get }
  /// The Request protocol.
  var requestProtocol: String { get }
  /// The default base URL (not including protocol).
  var baseURL: String { get }
  var authenticationRealm: String { get }
  var authenticationMethod: String { get }
  var protectionSpace: URLProtectionSpace { get }
}

public extension RequestConfiguration {
  func assign(to holder: RequestConfigurationHolder = RequestConfigurationHolder.shared) {
    holder.configuration = self
  }
}

/// The `RequestConfiguration` assigned to the `ReuqestConfigurationHolder` instance by default.
open class DefaultRequestConfiguration: RequestConfiguration {

  open var defaultHeaders: [String: String] {
    [
      "Accept": "application/json",
      "Content-Type": "application/json",
    ]
  }

  open var requestProtocol: String {
    Bundle.main.infoDictionary?["RequestProtocol"] as? String ?? "https"
  }

  /// - Important: This must be set in the app's **Info.plist**.
  open var baseURL: String {
    Bundle.main.infoDictionary?["BaseURL"] as? String ?? "test.url.com"
  }

  open var authenticationRealm: String {
    Bundle.main.infoDictionary?["AuthenticationRealm"] as? String ?? "Restricted"
  }

  open var authenticationMethod: String {
    NSURLAuthenticationMethodDefault
  }
  
  public var protectionSpace: URLProtectionSpace {
    URLProtectionSpace(host: baseURL,
                       port: 443,
                       protocol: requestProtocol,
                       realm: authenticationRealm,
                       authenticationMethod: authenticationMethod)
  }

  public init() {
  }
}
