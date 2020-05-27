//
//  RequestConfigurationTests.swift
//  
//
//  Created by Andrea Sacerdoti on 14/02/2020.
//

import XCTest
@testable import SwiftQuests

final class RequestConfigurationTests: XCTestCase {
  var configuration = DefaultRequestConfiguration()

  override func setUp() {
    super.setUp()
    configuration = DefaultRequestConfiguration()
  }

  func testAssign() {
    let holder = RequestConfigurationHolder()
    configuration.assign(to: holder)
    XCTAssertNotNil(holder.configuration)
  }
}
