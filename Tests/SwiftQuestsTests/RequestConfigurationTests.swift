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
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.timeoutIntervalForRequest = 2
        let session = URLSession(configuration: urlSessionConfiguration)
        configuration.defaultURLSession = session
        
        let holder = RequestConfigurationHolder()
        configuration.assign(to: holder)
        XCTAssertNotNil(holder.configuration)
        XCTAssertEqual(holder.configuration.defaultURLSession, session)
    }
}
