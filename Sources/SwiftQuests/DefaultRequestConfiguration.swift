//
//  DefaultRequestConfiguration.swift
//  
//
//  Created by Andrea Sacerdoti on 22/01/2020.
//

import Foundation

/// The protocol the app's specific configuration must implement.
public protocol RequestConfiguration {
    
    /// The default Request headers.
    ///
    /// Any headers passed to specific `Requests` would be appended to these.
    var defaultHeaders: [String: String] { get }
    
    /// The Request protocol.
    var requestProtocol: String { get }
    
    /// The default base URL (not including protocol).
    var baseURL: String { get }
    
    /// The default port.
    var port: Int { get }
    
    /// The server's authentication realm.
    var authenticationRealm: String { get }
    
    /// The default authentication method to use with Requests.
    var authenticationMethod: String { get }
    
    /// The default `URLSession` used for all `Request`s.
    var defaultURLSession: URLSession { get }
}

public extension RequestConfiguration {
    
    /// The URLProtectionSpace generated by the configuration properties.
    var protectionSpace: URLProtectionSpace {
        URLProtectionSpace(host: baseURL,
                           port: port,
                           protocol: requestProtocol,
                           realm: authenticationRealm,
                           authenticationMethod: authenticationMethod)
    }
}

public extension RequestConfiguration {
    
    /// Sets the configuration as default for a given `RequestConfigurationHolder`.
    ///
    /// Assigns the configuration to a given `RequestConfigurationHolder`. The configuration will be used
    /// as the default for all subsequent Requests.
    ///
    /// - Parameter holder: The holder receiving the configuration. Defaults to the shared instance.
    func assign(to holder: RequestConfigurationHolder = RequestConfigurationHolder.shared) {
        holder.configuration = self
    }
}

/// The `RequestConfiguration` assigned to the `RequestConfigurationHolder` instance by default.
open class DefaultRequestConfiguration: RequestConfiguration {
    
    open var defaultHeaders: [String: String] = [
        "Accept": "application/json",
        "Content-Type": "application/json",
    ]
    
    open var requestProtocol = "https"
    
    open var baseURL = "test.url.com"
    
    open var port = 443
    
    open var authenticationRealm = "Restricted"
    
    open var authenticationMethod = NSURLAuthenticationMethodDefault
    
    open var defaultURLSession = URLSession(configuration: .ephemeral)
    
    public init() {
    }
}
