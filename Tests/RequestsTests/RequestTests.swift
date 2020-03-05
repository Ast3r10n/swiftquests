//
//  RequestTests.swift
//
//
//  Created by Andrea Sacerdoti on 16.10.2019.
//

import XCTest
@testable import Requests

final class RequestTests: XCTestCase {
  var request: Request?

  override func setUp() {
    super.setUp()
    request = try? Request(.get,
                           atPath: "/user",
                           parameters: ["user": "12345"],
                           body: try? JSONSerialization.data(withJSONObject: ["testBody": "thisisatest"],
                                                             options: .fragmentsAllowed),
                           headers: ["Content-Type": "application/json"],
                           using: URLCredential(user: "test",
                                                password: "testPassword",
                                                persistence: .forSession),
                           onSession: URLSessionMock(),
                           configuration: DefaultRequestConfiguration())
  }

  func testInitMethod() {
    XCTAssertEqual(request?.method, RESTMethod(rawValue: "GET"))
  }

  func testInitResourcePath() {
    XCTAssertEqual(request?.resourcePath, URLComponents(string: "/user")?.url?.absoluteString)
  }

  func testInitParameters() {
    XCTAssertEqual(request?.parameters?["user"], "12345")
  }

  func testInitBody() {
    XCTAssertEqual(request?.urlRequest?.httpBody,
                   try? JSONSerialization.data(withJSONObject: ["testBody": "thisisatest"],
                                               options: .fragmentsAllowed))
  }

  func testInitHeaders() {
    XCTAssertEqual(request?.urlRequest?.allHTTPHeaderFields?["Content-Type"], "application/json")
  }

  func testInitCredential() {
    XCTAssertEqual(request?.credential, URLCredential(user: "test",
                                                      password: "testPassword",
                                                      persistence: .forSession))
  }

  func testInitThrow() {
    XCTAssertThrowsError(try Request(.get, atPath: "asd"))
  }

  func testInitConfiguration() {
    XCTAssertEqual(request?.configuration.baseURL, DefaultRequestConfiguration().baseURL)
  }

  func testPerform() {
    let resultExpectation = expectation(description: "Request should perform correctly")

    request?.perform { result in

      XCTAssertNoThrow(try result.get())
      resultExpectation.fulfill()
    }

    wait(for: [resultExpectation], timeout: 5)
  }

  func testPerformErrorReturn() {
    let throwExpectation = expectation(description: "Perform should throw an error")
    let session = URLSessionMock()
    session.error = NSError(domain: "test", code: 42, userInfo: [NSLocalizedDescriptionKey: "Test error"])

    try? Request(.get,
                 atPath: "/test",
                 onSession: session)
      .perform { result in

        XCTAssertThrowsError(try result.get())
        throwExpectation.fulfill()
    }

    wait(for: [throwExpectation], timeout: 5)
  }

  func testPerformDecoding() {
    let decodingExpectation = expectation(description: "Object should decode correctly")

    try? Request(.get,
                 atPath: "/user",
                 onSession: URLSessionCodableMock())
      .perform(decoding: User.self) { result in

        if let response = try? result.get(),
          response.0?.username == "test" {

          decodingExpectation.fulfill()
        }
    }

    wait(for: [decodingExpectation], timeout: 5)
  }

  func testPerformDecodingError() {
    let throwingExpectation = expectation(description: "Perform should throw an error")
    let sessionMock = URLSessionCodableMock()
    sessionMock.data = nil

    try? Request(.get,
                 atPath: "/user",
                 onSession: sessionMock)
      .perform(decoding: User.self) { result in

        XCTAssertThrowsError(try result.get())
        throwingExpectation.fulfill()
    }

    wait(for: [throwingExpectation], timeout: 5)
  }

  func testPerformDecodingPerformError() {
    let throwingExpectation = expectation(description: "Perform should throw an error")
    let sessionMock = URLSessionCodableMock()
    sessionMock.error = NSError(domain: "test", code: 42, userInfo: [NSLocalizedDescriptionKey: "Test error"])

    try? Request(.get,
                 atPath: "/user",
                 onSession: sessionMock)
      .perform(decoding: User.self) { result in

        XCTAssertThrowsError(try result.get())
        throwingExpectation.fulfill()
    }

    wait(for: [throwingExpectation], timeout: 5)
  }

  static var allTests = [
    ("testInit", testInitMethod),
    ("testInitResourcePath", testInitResourcePath),
    ("testInitParameters", testInitParameters),
    ("testInitHeaders", testInitHeaders),
    ("testInitBody", testInitBody),
    ("testPerform", testPerform),
  ]
}
