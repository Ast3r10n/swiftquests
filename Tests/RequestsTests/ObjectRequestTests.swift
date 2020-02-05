//
//  File.swift
//  
//
//  Created by Andrea Sacerdoti on 01/11/2019.
//

import XCTest
@testable import Requests

final class ObjectRequestTests: XCTestCase {
  var request: ObjectRequest<User>?

  override func setUp() {
    super.setUp()
    request = try? ObjectRequest(.get,
                                 User.self,
                                 atPath: "/user",
                                 on: URLSessionMock())
  }

  func testObjectInit() {
    XCTAssertNotNil(request?.object)
  }

  func testObjectPerform() {
    let resultExpectation = expectation(description: "Object should be decoded correctly.")

    try? request?.perform { object, response, error in
      if error == nil,
        object as? User != nil {
        resultExpectation.fulfill()
      }
    }

    wait(for: [resultExpectation], timeout: 5)
  }
}
