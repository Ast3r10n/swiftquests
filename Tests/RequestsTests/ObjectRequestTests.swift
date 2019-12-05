//
//  File.swift
//  
//
//  Created by Andrea Sacerdoti on 01/11/2019.
//

import XCTest
@testable import Requests

final class ObjectRequestTests: XCTestCase {
  func testInitObject() {
    var request: ObjectRequest<User>?
    XCTAssertNotNil(request?.object)
    request = try? ObjectRequest(.get, "user")

    XCTAssertEqual(request?.method, RequestMethod(rawValue: "GET"))
    XCTAssertEqual(request?.resourcePath, URLComponents(string: "user")?.url?.absoluteString)

    XCTAssertEqual(request?.urlRequest?.allHTTPHeaderFields?["Content-Type"], "application/json")
  }
}
