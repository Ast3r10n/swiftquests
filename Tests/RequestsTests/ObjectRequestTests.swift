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
    let request = try? ObjectRequest(.get, User.self, atPath: "user")
    XCTAssertNotNil(request?.object)
  }
}
