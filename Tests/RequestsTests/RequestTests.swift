//
//  RequestTests.swift
//
//
//  Created by Andrea Sacerdoti on 16.10.2019.
//

import XCTest
@testable import Requests

final class RequestTests: XCTestCase {
  func testInit() {
    var request: Request?
    do {
      request = try Request(.post, "user", parameters: ["user": "12345"], body: ["testBody": "thisisatest"])
    } catch {
      XCTFail(error.localizedDescription)
    }

    XCTAssertEqual(request?.method, RequestMethod(rawValue: "POST"))
    XCTAssertEqual(request?.resourcePath, URLComponents(string: "user")?.url?.absoluteString)
    XCTAssertEqual(request?.parameters?["user"] as? String, "12345")
    XCTAssertNotNil(request?.body)
    XCTAssertEqual(request?.urlRequest?.allHTTPHeaderFields?["Content-Type"], "application/json")
    XCTAssertEqual(request?.urlRequest?.httpBody, try! JSONSerialization.data(withJSONObject: ["testBody": "thisisatest"], options: .fragmentsAllowed))
  }

  func testPerform() {
    let resultExpectation = expectation(description: "Request should perform correctly")

    do {
      try Request(.get, "profile").perform { data, response, error in
        if error == nil {
          resultExpectation.fulfill()
        }
      }
    } catch {
      XCTFail(error.localizedDescription)
    }

    wait(for: [resultExpectation], timeout: 5)
  }

  static var allTests = [
    ("testInit", testInit),
    ("testPerform", testPerform)
  ]
}
