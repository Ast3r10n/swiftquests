//
//  Request.swift
//
//
//  Created by Andrea Sacerdoti on 16.10.2019.
//

import Foundation

/// An enum of CRUD REST method strings.
public enum RESTMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

/// A typealias of a successful response.
public typealias Response = (data: Data?, urlResponse: URLResponse?)

/// A common interface for `Request`s and `RequestDecorator`s.
public protocol AbstractRequest {
    @available(macOS 12, iOS 13, watchOS 8, tvOS 15, *)
    func perform() async throws -> Response
    func perform(_ completionHandler: @escaping (_ result: Result<Response, Error>) throws -> Void)
}

/// Implemented by decorators to allow `request` overrides.
public protocol RequestDecorator: AbstractRequest {
    
    /// The `AbstractRequest` to decorate.
    var request: AbstractRequest { get set }
}

/// A basic RESTful request object.
///
/// A `Request` object is a standalone task which should only exist within the scope of the request. Once initialised,
/// use either the `perform(_:)` or `perform(decoding:_:)` methods to launch the request.
/// `Request` properties are constants and only set within the initialiser.
open class Request: AbstractRequest {

    // MARK: - Public Properties
    /// The request REST method.
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
    public var session = URLSession(configuration: .ephemeral)
    
    /// The wrapped `URLRequest` object.
    public var urlRequest: URLRequest!

    /// The request configuration.
    ///
    /// Defaults to the configuration stored in the `RequestConfigurationHolder` `shared` instance unless otherwise
    /// specified.
    open private(set) var configuration: RequestConfiguration = RequestConfigurationHolder.shared.configuration

    // MARK: - Public Methods
    /// Creates a `Request` with the specified properties.
    /// - Parameters:
    ///   - method: A REST method.
    ///   - resourcePath: The resource path the request points to.
    ///   - parameters: A dictionary of parameters. Defaults to nil.
    ///   - body: An encoded body. Defaults to nil.
    ///   - headers: A dictionary of headers to be appended to the configuration's `defaultHeaders`. Defaults to nil.
    ///   - credential: A specific `URLCredential` to use with the request. Defaults to nil.
    ///   - session: A specific `URLSession` to use with the request. Defaults to nil.
    ///   - configuration: A specific `RequestConfiguration` to use with the request. Defaults to nil.
    /// - Throws: An error if the `resourcePath` is malformed.
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

    /// Performs the request asynchronously.
    /// - Throws: An error if either the `urlRequest` property was not properly initialised, or the task throws.
    @available(macOS 12, iOS 13, watchOS 8, tvOS 15, *)
    open func perform() async throws -> Response {
        if let credential = credential {
            URLCredentialStorage.shared.set(
                credential,
                for: configuration.protectionSpace)
        }

        let response = try await session.data(for: urlRequest)
        if let statusCode = (response.1 as? HTTPURLResponse)?.statusCode,
           !(200..<300 ~= statusCode) {

            throw NetworkError.identifying(statusCode: statusCode)
        }

        return response
    }
    
    /// Performs the request, then executes the code block passed to the `completionHandler`.
    /// - Parameters:
    ///   - completionHandler: An handler called upon completion.
    ///   - result: The response result.
    /// - Throws: An error if either the `urlRequest` property was not properly initialised, or the `completionHandler`
    ///   throws.
    open func perform(_ completionHandler: @escaping (_ result: Result<Response, Error>) throws -> Void) {

        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                try? completionHandler(.failure(error))
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode,
               !(200..<300 ~= statusCode) {
                
                try? completionHandler(.failure(NetworkError.identifying(statusCode: statusCode)))
                return
            }
            
            try? completionHandler(.success((data, response)))
        }
        
        if let credential = credential {
            URLCredentialStorage.shared.set(
                credential,
                for: configuration.protectionSpace,
                task: task)
        }
        
        task.resume()
    }

    /// Performs the request asynchronously,, trying to decode a specified `object` from the response.
    /// - Parameters:
    ///   - object: An object type to decode from the response data.
    ///   - result: The response result.
    @available(macOS 12, iOS 13, watchOS 8, tvOS 15, *)
    public func perform<T: Decodable>(decoding object: T.Type) async throws -> (T, URLResponse?) {
        let result = try await perform()
        guard let data = result.data,
              !data.isEmpty else {
            throw NSError(domain: "Request decoding",
                          code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Data returned nil."])
        }

        return try (JSONDecoder().decode(T.self, from: data), result.urlResponse)
    }
    
    /// Performs the request, trying to decode a specified `object` from the response,
    /// and calls a handler upon completion.
    /// - Parameters:
    ///   - object: An object type to decode from the response data.
    ///   - completionHandler: An handler called upon completion.
    ///   - result: The response result.
    public func perform<T: Decodable>(
        decoding object: T.Type,
        _ completionHandler: @escaping (
            _ result: Result<(T, URLResponse?), Error>) throws -> Void) {
                
                perform { result in
                    switch result {
                    case .success(let response):
                        guard let data = response.data,
                              !data.isEmpty else {
                                  try completionHandler(.failure(NSError(domain: "",
                                                                         code: 0,
                                                                         userInfo: [NSLocalizedDescriptionKey: "Data returned nil."])))
                                  return
                              }
                        
                        do {
                            let object = try JSONDecoder().decode(T.self, from: data)
                            try completionHandler(.success((object, response.urlResponse)))
                        } catch let error {
                            try completionHandler(.failure(error))
                        }
                        
                    case .failure(let error):
                        try completionHandler(.failure(error))
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
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        configuration.defaultHeaders.forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        if let headers {
            headers.forEach { header in
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        if let body {
            request.httpBody = body
        }
        
        return request
    }
    
    private lazy var requestComponents: URLComponents = {
        var components = URLComponents()
        components.scheme = configuration.requestProtocol
        components.host = configuration.baseURL
        components.port = configuration.port
        components.path = resourcePath
        
        if let parameters = parameters {
            add(parameters, to: &components)
        }
        
        return components
    }()
    
    private func add(_ parameters: [String: String], to urlComponents: inout URLComponents) {
        if urlComponents.queryItems == nil {
            urlComponents.queryItems = []
        }
        
        parameters.forEach { parameter in
            urlComponents.queryItems?.append(URLQueryItem(name: parameter.key, value: parameter.value))
        }
    }
}
