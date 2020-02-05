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
  case patch = "PATCH"
}

open class Request {
  // MARK: - Properties
  public let method: RequestMethod
  
  public let resourcePath: String
  public let parameters: [String: String]?
  public let body: Data?
  public let headers: [String: String]?
  public let credential: URLCredential?

  private var session = URLSession(configuration: .default)
  public private(set) var urlRequest: URLRequest?
  open private(set) var configuration: RequestConfiguration = RequestConfigurationHolder.shared.configuration

  // MARK: - Public Methods
  public init(_ method: RequestMethod,
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

  public func perform(_ completionHandler: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: Error?) throws -> Void)) throws {

    guard let request = urlRequest else {
      try completionHandler(nil, nil, NSError(domain: "Request", code: 0, userInfo: [NSLocalizedDescriptionKey: "Request not initialized."]))
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
