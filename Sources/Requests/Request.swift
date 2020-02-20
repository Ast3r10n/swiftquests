//
//  Request.swift
//
//
//  Created by Andrea Sacerdoti on 16.10.2019.
//

import Foundation

/// An enum of REST method strings.
public enum RESTMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
  case patch = "PATCH"
}

/// A common interface for `Request`s and `RequestDecorator`s.
public protocol AbstractRequest {
  func perform(_ completionHandler: @escaping (
    _ data: Data?,
    _ response: URLResponse?,
    _ error: Error?) throws -> Void) throws
}

/// Implemented by decorators to allow `request` overrides.
public protocol RequestDecorator: AbstractRequest {
  /// The `AbstractRequest` to decorate.
  var request: AbstractRequest { get set }
}

/// A base RESTful request object.
open class Request: AbstractRequest {
  // MARK: - Properties
  public let method: RESTMethod
  /// The resource path URL component.
  ///
  /// - Note: Must begin with a forward slash ("/"), otherwise the `Request` `init` will throw an error.
  public let resourcePath: String
  /// The request parameters.
  ///
  /// - Note: Do not use this for the request body: use the `body` argument instead.
  public let parameters: [String: String]?
  /// The encoded request body.
  public let body: Data?
  /// The request headers.
  ///
  /// These headers will be appended to the specified `RequestConfiguration` `defaultHeaders`.
  public let headers: [String: String]?
  /// The `URLCredential` to be used for the request.
  ///
  /// If not provided, the request will use the default credential
  /// stored in the `URLCredentialStorage` `shared` instance.
  public let credential: URLCredential?
  /// The request `URLSession`.
  ///
  /// Defaults to a session with a `default` `URLSessionConfiguration` unless otherwise specified.
  public var session = URLSession(configuration: .default)
  /// The wrapped `URLRequest` object.
  public private(set) var urlRequest: URLRequest?
  /// The request configuration.
  ///
  /// Defaults to the configuration stored in the `RequestConfigurationHolder` `shared` instance unless otherwise
  /// specified.
  open private(set) var configuration: RequestConfiguration = RequestConfigurationHolder.shared.configuration

  // MARK: - Public Methods
  /// Creates a `Request` with the specified properties.
  public init(_ method: RESTMethod,
              atPath resourcePath: String,
              parameters: [String: String]? = nil,
              body: Data? = nil,
              headers: [String: String]? = nil,
              using credential: URLCredential? = nil,
              onSession session: URLSession? = nil,
              configuration: RequestConfiguration? = nil) throws {

    self.method = method
    self.resourcePath = resourcePath
    self.parameters = parameters
    self.body = body
    self.headers = headers
    self.credential = credential

    if let configuration = configuration {
      self.configuration = configuration
    }

    if let session = session {
      self.session = session
    }

    self.urlRequest = try prepare()
  }

  public func perform(_ completionHandler: @escaping (
    _ data: Data?,
    _ response: URLResponse?,
    _ error: Error?) throws -> Void) throws {

    guard let request = urlRequest else {
      try completionHandler(nil, nil, NSError(domain: "Request",
                                              code: 0,
                                              userInfo: [NSLocalizedDescriptionKey: "Request not initialized."]))
      return
    }

    let task = session.dataTask(with: request) { data, response, error in
      try? completionHandler(data, response, error)
    }

    if let credential = credential {
      URLCredentialStorage.shared.set(credential,
                                      for: configuration.protectionSpace,
                                      task: task)
    }

    task.resume()
  }

  public func perform<T: Codable>(decoding object: T.Type,
                                  _ completionHandler: @escaping (
    _ data: T?,
    _ response: URLResponse?,
    _ error: Error?) -> Void) throws {

    try perform { data, response, error in
      if error == nil,
        let data = data {

        completionHandler(try JSONDecoder().decode(T.self, from: data), response, error)
      }
    }
  }

  // MARK: - Private Methods
  private func prepare() throws -> URLRequest {
    guard let url = requestComponents.url else {
      throw NSError(domain: "Request",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid request URL."])
    }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method.rawValue

    configuration.defaultHeaders.forEach { header in
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

  private var requestComponents: URLComponents {
    var components = URLComponents()
    components.scheme = configuration.requestProtocol
    components.host = configuration.baseURL
    components.path = resourcePath

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
