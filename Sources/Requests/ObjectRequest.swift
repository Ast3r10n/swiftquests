//
//  ObjectRequest.swift
//  
//
//  Created by Andrea Sacerdoti on 01/11/2019.
//

import Foundation

open class ObjectRequest<T: Decodable>: Request {
  // MARK: - Properties
  public let object: T.Type

  // MARK: - Public Methods
  public func perform(_ completionHandler: @escaping ((T?, URLResponse?, Error?) throws -> Void)) throws {
    try super.perform { data, response, error in

      guard let data = data,
        error == nil else {
          try completionHandler(nil, response, error)
          return
      }
      
      try completionHandler(try JSONDecoder().decode(object, from: data), response, error)
    }
  }

  // MARK: - Private Methods
  override public init(_ method: RequestMethod, _ resourcePath: String, parameters: [String : Any]? = nil, body: Data? = nil, headers: [String : String]? = nil, using credential: URLCredential? = nil) throws {
    <#code#>
  }
}
