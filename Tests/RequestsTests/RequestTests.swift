//
//  RequestTests.swift
//
//
//  Created by Andrea Sacerdoti on 16.10.2019.
//

import XCTest
@testable import Requests

final class RequestTests: XCTestCase {
  var request: Request? = nil

  override func setUp() {
    super.setUp()
    request = try? Request(.get,
                           atPath: "user",
                           parameters: ["user": "12345"],
                           body: try? JSONSerialization.data(withJSONObject: ["testBody": "thisisatest"], options: .fragmentsAllowed),
                           headers: ["Content-Type": "application/json"])
  }

  func testInitMethod() {
    XCTAssertEqual(request?.method, RequestMethod(rawValue: "GET"))
  }

  func testInitResourcePath() {
    XCTAssertEqual(request?.resourcePath, URLComponents(string: "user")?.url?.absoluteString)
  }

  func testInitParameters() {
    XCTAssertEqual(request?.parameters?["user"], "12345")
  }

  func testInitBody() {
    XCTAssertEqual(request?.urlRequest?.httpBody, try! JSONSerialization.data(withJSONObject: ["testBody": "thisisatest"], options: .fragmentsAllowed))
  }

  func testInitHeaders() {
     XCTAssertEqual(request?.urlRequest?.allHTTPHeaderFields?["Content-Type"], "application/json")
  }

  func testPerform() {
    let resultExpectation = expectation(description: "Request should perform correctly")

    do {
      try Request(.get, atPath: "profile").perform { data, response, error in
        if let error = error {
          XCTFail(error.localizedDescription)
        }
        resultExpectation.fulfill()
      }
    } catch {
      XCTFail(error.localizedDescription)
    }

    wait(for: [resultExpectation], timeout: 5)
  }

  static var allTests = [
    ("testInit", testInitMethod),
    ("testInitResourcePath", testInitResourcePath),
    ("testInitParameters", testInitParameters),
    ("testInitHeaders", testInitHeaders),
    ("testInitBody", testInitBody),
    ("testPerform", testPerform)
  ]
}
