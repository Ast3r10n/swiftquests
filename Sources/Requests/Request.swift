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
  public let method: RequestMethod
  public let resourcePath: String
  public let parameters: [String: Any]?
  public let body: [String: Any]?
  private let credential: URLCredential?
  public private(set) var urlRequest: URLRequest?

  public init(_ method: RequestMethod,
       _ resourcePath: String,
       parameters: [String: Any]? = nil,
       body: [String: Any]? = nil,
       using credential: URLCredential? = nil) throws {
    self.method = method
    self.resourcePath = resourcePath
    self.parameters = parameters
    self.body = body
    self.credential = credential
    self.urlRequest = try prepare()
  }

  // MARK: - Public Methods
  public func perform(_ completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Void)) throws {
    guard let request = urlRequest else {
      throw NSError(domain: "Request", code: 0, userInfo: [NSLocalizedDescriptionKey: "Request not initialized."])
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      completionHandler(data, response, error)
    }

    if let credential = credential {
      URLCredentialStorage.shared.set(credential, for: defaultProtectionSpace, task: task)
    }

    task.resume()
  }

  // MARK: - Private Methods
  private func prepare() throws -> URLRequest {
    guard let url = requestComponents().url else {
      throw NSError(domain: "Request", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid request URL."])
    }

    var urlRequest = URLRequest(url: url)

    for header in defaultHeaders {
      urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
    }

    if let body = body {
      urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
    }

    return urlRequest
  }

  private func requestComponents() -> URLComponents {
    var requestURL = URLComponents()
    requestURL.scheme = requestProtocol
    requestURL.host = baseURL
    requestURL.path = "/\(resourcePath)"

    if let parameters = parameters {
      add(parameters, to: &requestURL)
    }

    return requestURL
  }

  private func add(_ parameters: [String: Any], to urlComponents: inout URLComponents) {
    if urlComponents.queryItems == nil {
      urlComponents.queryItems = []
    }

    parameters.forEach { parameter in
      urlComponents.queryItems?.append(URLQueryItem(name: parameter.key, value: parameter.value as? String))
    }
  }
}
