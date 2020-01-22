//
//  Request.swift
//
//
//  Created by Andrea Sacerdoti on 16.10.2019.
//

import Foundation

public enum RequestMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}

open class Request {
  // MARK: - Properties
  public let method: RequestMethod
  
  public let resourcePath: String
  public let parameters: [String: String]?
  public let body: Data?
  public let headers: [String: String]?
  private let credential: URLCredential?
<<<<<<< HEAD
  private let configuration: RequestConfiguration
=======
  private var session = URLSession(configuration: .default)
>>>>>>> feature/codable
  public private(set) var urlRequest: URLRequest?

  private var defaultHeaders: [String: String] {
    [
      "Accept": "application/json",
      "Content-Type": "application/json",
    ]
  }

  private var requestProtocol: String {
    Bundle.main.infoDictionary?["RequestProtocol"] as? String ?? "https"
  }

  /// - Important: This must be set in the app's **Info.plist**.
  private var baseURL: String {
    Bundle.main.infoDictionary?["BaseURL"] as? String ?? "test.url.com"
  }

  private var authenticationRealm: String {
    Bundle.main.infoDictionary?["AuthenticationRealm"] as? String ?? "Restricted"
  }

  private var defaultProtectionSpace: URLProtectionSpace {
    URLProtectionSpace(host: baseURL,
                       port: 443,
                       protocol: requestProtocol,
                       realm: authenticationRealm,
                       authenticationMethod: NSURLAuthenticationMethodDefault)
  }

  // MARK: - Public Methods
  public init(_ method: RequestMethod,
              atPath resourcePath: String,
              parameters: [String: String]? = nil,
              body: Data? = nil,
              headers: [String: String]? = nil,
              using credential: URLCredential? = nil,
              on session: URLSession? = nil) throws {

    self.method = method
    self.resourcePath = resourcePath
    self.parameters = parameters
    self.body = body
    self.headers = headers
    self.credential = credential

    if let session = session {
      self.session = session
    }

    self.urlRequest = try prepare()
  }

  public func perform(_ completionHandler: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: Error?) throws -> Void)) throws {
    guard let request = urlRequest else {
      try completionHandler(nil, nil, NSError(domain: "Request", code: 0, userInfo: [NSLocalizedDescriptionKey: "Request not initialized."]))
      return
    }

    let task = session.dataTask(with: request) { data, response, error in
      try? completionHandler(data, response, error)
    }

    if let credential = credential {
      URLCredentialStorage.shared.set(credential, for: configuration.defaultProtectionSpace, task: task)
    }

    task.resume()
  }

  // MARK: - Private Methods
  private func prepare() throws -> URLRequest {
    guard let url = requestComponents().url else {
      throw NSError(domain: "Request", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid request URL."])
    }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method.rawValue


    defaultHeaders.forEach { header in
      urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
    }

    if let headers = headers {
      headers.forEach { header in
        urlRequest.addValue(header.key, forHTTPHeaderField: header.value)
      }
    }

    if let body = body {
      urlRequest.httpBody = body
    }

    return urlRequest
  }

  private func requestComponents() -> URLComponents {

    var components = URLComponents()
    components.scheme = requestProtocol
    components.host = baseURL
    components.path = "/\(resourcePath)"

    if let parameters = parameters {
      add(parameters, to: &components)
    }

    return components
  }

  private func add(_ parameters: [String: String], to urlComponents: inout URLComponents) {
    if urlComponents.queryItems == nil {
      urlComponents.queryItems = []
    }

    parameters.forEach { parameter in
      urlComponents.queryItems?.append(URLQueryItem(name: parameter.key, value: parameter.value))
    }
  }
}
