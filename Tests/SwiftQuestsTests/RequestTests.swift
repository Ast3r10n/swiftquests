//
//  RequestTests.swift
//
//
//  Created by Andrea Sacerdoti on 16.10.2019.
//

import XCTest
@testable import SwiftQuests

final class RequestTests: XCTestCase {
  var request: Request?

  var session = URLSession(configuration: .ephemeral)

  override func setUp() {
    super.setUp()
    URLProtocolMock.response = nil
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [URLProtocolMock.self]
    session = URLSession(configuration: configuration)
    request = try? Request(.get,
                           atPath: "/user",
                           parameters: ["user": "12345"],
                           body: try? JSONSerialization.data(withJSONObject: ["testBody": "thisisatest"],
                                                             options: .fragmentsAllowed),
                           headers: ["Content-Type": "application/json"],
                           using: URLCredential(user: "test",
                                                password: "testPassword",
                                                persistence: .forSession),
                           onSession: session,
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
    URLProtocolMock.response = (nil, nil, NSError(domain: "test",
                                                    code: 42,
                                                    userInfo: [NSLocalizedDescriptionKey: "Test error"]))


    try? Request(.get,
                 atPath: "/test",
                 onSession: session)
      .perform { result in

        XCTAssertThrowsError(try result.get())
        throwExpectation.fulfill()
    }

    wait(for: [throwExpectation], timeout: 5)
  }

  func testPerformStatusCodeErrorReturn() {
    let throwExpectation = expectation(description: "Perform should throw an error")
    let session = URLSessionMock()
    session.response = HTTPURLResponse(url: URL(string: "https://test.com/test")!,
                                       statusCode: 404,
                                       httpVersion: nil,
                                       headerFields: [:])

    try? Request(.get,
                 atPath: "/test",
                 onSession: session)
      .perform { result in

        if case .failure(let error) = result {
          XCTAssertEqual(error as? NetworkError, NetworkError.notFound)
          throwExpectation.fulfill()
        }
      }

    wait(for: [throwExpectation], timeout: 5)
  }

  func testPerformDecoding() {
    let decodingExpectation = expectation(description: "Object should decode correctly")
    let user = User()
    user.username = "test"
    URLProtocolMock.response = (try? JSONEncoder().encode(user), nil, nil)

    try? Request(.get,
                 atPath: "/user",
                 onSession: session)
      .perform(decoding: User.self) { result in

        if let response = try? result.get(),
          response.0.username == "test" {

          decodingExpectation.fulfill()
        }
    }

    wait(for: [decodingExpectation], timeout: 5)
  }

  func testPerformDecodingError() {
    let throwingExpectation = expectation(description: "Perform should throw an error")
    URLProtocolMock.response = (Data(base64Encoded: "VEhJU0lTV1JPTkc="), nil, nil)

    try? Request(.get,
                 atPath: "/user",
                 onSession: session)
      .perform(decoding: User.self) { result in

        XCTAssertThrowsError(try result.get())
        throwingExpectation.fulfill()
    }

    wait(for: [throwingExpectation], timeout: 500)
  }

  func testPerformDecodingNoDataError() {
    let throwingExpectation = expectation(description: "Perform should throw an error")

    try? Request(.get,
                 atPath: "/user",
                 onSession: session)
      .perform(decoding: User.self) { result in

        XCTAssertThrowsError(try result.get())
        throwingExpectation.fulfill()
    }

    wait(for: [throwingExpectation], timeout: 5)
  }

  func testPerformDecodingPerformError() {
    let throwingExpectation = expectation(description: "Perform should throw an error")
    URLProtocolMock.response = (nil, nil, NSError(domain: "test", code: 42, userInfo: [NSLocalizedDescriptionKey: "Test error"]))

    try? Request(.get,
                 atPath: "/user",
                 onSession: session)
      .perform(decoding: User.self) { result in

        XCTAssertThrowsError(try result.get())
        throwingExpectation.fulfill()
    }

    wait(for: [throwingExpectation], timeout: 5)
  }
}
