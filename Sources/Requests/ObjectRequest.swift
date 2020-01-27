//
//  ObjectRequest.swift
//  
//
//  Created by Andrea Sacerdoti on 17/12/2019.
//

import Foundation

open class ObjectRequest<T: Codable>: Request {
  // MARK: - Public Properties
  public let object: T.Type

  // MARK: - Public Methods
  init(_ method: RequestMethod,
                _ object: T.Type,
                atPath resourcePath: String,
                parameters: [String : String]? = nil,
                body: Data? = nil,
                headers: [String : String]? = nil,
                using credential: URLCredential? = nil,
                on session: URLSession? = nil) throws {
    self.object = object

    try super.init(method,
               atPath: resourcePath,
               parameters: parameters,
               body: body,
               headers: headers,
               using: credential,
               on: session)

  }

  func perform(_ completionHandler: @escaping ((T?, URLResponse?, Error?) throws -> Void)) throws {
    try perform { data, response, error in
      var object: T? = nil
      if let data = data {
        object = try JSONDecoder().decode(T.self, from: data)
      }

      try completionHandler(object, response, error)
    }
  }
}
