//
//  NetworkErrorTests.swift
//  
//
//  Created by Andrea Sacerdoti on 02/07/21.
//

import XCTest
@testable import SwiftQuests

final class NetworkErrorTests: XCTestCase {

  func testErrorDescription() {
    XCTAssertNotNil(NetworkError.generic.errorDescription)
    XCTAssertNotNil(NetworkError.badRequest.errorDescription)
    XCTAssertNotNil(NetworkError.unauthorized.errorDescription)
    XCTAssertNotNil(NetworkError.forbidden.errorDescription)
    XCTAssertNotNil(NetworkError.notFound.errorDescription)
    XCTAssertNotNil(NetworkError.internalServerError.errorDescription)
    XCTAssertEqual(NetworkError.withDescription("Test Description").localizedDescription, "Test Description")
  }

  func testIdentifying() {
    XCTAssertEqual(NetworkError.identifying(statusCode: 400), .badRequest)
    XCTAssertEqual(NetworkError.identifying(statusCode: 401), .unauthorized)
    XCTAssertEqual(NetworkError.identifying(statusCode: 403), .forbidden)
    XCTAssertEqual(NetworkError.identifying(statusCode: 404), .notFound)
    XCTAssertEqual(NetworkError.identifying(statusCode: 405), .generic)
    XCTAssertEqual(NetworkError.identifying(statusCode: 500), .internalServerError)
  }
}
