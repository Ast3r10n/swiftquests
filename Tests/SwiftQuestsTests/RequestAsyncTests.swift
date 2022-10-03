//
//  RequestTests.swift
//
//
//  Created by Andrea Sacerdoti on 16.10.2019.
//

import XCTest
@testable import SwiftQuests

@available(macOS 12, iOS 13, watchOS 8, tvOS 15, *)
final class RequestAsyncTests: XCTestCase {
    var request: Request!
    
    var session = URLSession(configuration: .ephemeral)
    
    override func setUpWithError() throws {
        super.setUp()
        URLProtocolMock.response = ("Test".data(using: .utf8),
                                    HTTPURLResponse(url: try XCTUnwrap(URL(string: "https://test.com/test")),
                                                    statusCode: 200,
                                                    httpVersion: nil,
                                                    headerFields: [:]),
                                    nil)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: configuration)
        request = try XCTUnwrap(Request(.get,
                                        atPath: "/user",
                                        parameters: ["user": "12345"],
                                        body: JSONSerialization.data(withJSONObject: ["testBody": "thisisatest"],
                                                                     options: .fragmentsAllowed),
                                        headers: ["Content-Type": "application/json"],
                                        using: URLCredential(user: "test",
                                                             password: "testPassword",
                                                             persistence: .forSession),
                                        onSession: session,
                                        configuration: DefaultRequestConfiguration()))
    }
    
    func testPerformAsync() async throws {
        let response = try await request.perform()
        XCTAssertNoThrow(response)
    }
    
    func testPerformAsyncStatusCodeErrorReturn() async throws {
        URLProtocolMock.response = (nil,
                                    HTTPURLResponse(url: try XCTUnwrap(URL(string: "https://test.com/test")),
                                                    statusCode: 404,
                                                    httpVersion: nil,
                                                    headerFields: [:]),
                                    nil)
        do {
            let _ = try await request.perform()
        } catch {
            XCTAssertEqual((error as NSError).code, 5)
        }
    }
    
    func testPerformAsyncDecoding() async throws {
        let user = User()
        user.username = "test"
        URLProtocolMock.response = (try JSONEncoder().encode(user),
                                    HTTPURLResponse(url: try XCTUnwrap(URL(string: "https://test.com/test")),
                                                    statusCode: 200,
                                                    httpVersion: nil,
                                                    headerFields: [:]),
                                    nil)
        
        let result = try await request.perform(decoding: User.self)
        XCTAssertEqual(result.0.username, "test")
    }
    
    func testPerformAsyncDecodingError() async throws {
        URLProtocolMock.response = (Data(base64Encoded: "VEhJU0lTV1JPTkc="),
                                    HTTPURLResponse(url: URL(string: "https://test.com/test")!,
                                                    statusCode: 200,
                                                    httpVersion: nil,
                                                    headerFields: [:]),
                                    nil)

        do {
            let _ = try await request.perform(decoding: User.self)
        } catch {
            XCTAssertEqual((error as NSError).code, 4864)
        }
    }
    
    func testPerformAsyncDecodingNoDataError() async throws {
        URLProtocolMock.response = (nil,
                                    HTTPURLResponse(url: URL(string: "https://test.com/test")!,
                                                    statusCode: 200,
                                                    httpVersion: nil,
                                                    headerFields: [:]),
                                    nil)
        
        do {
            let _ = try await request.perform(decoding: User.self)
        } catch {
            XCTAssertEqual((error as NSError).code, 404)
        }
    }
    
    func testPerformAsyncDecodingPerformError() async throws {
        URLProtocolMock.response = (nil,
                                    HTTPURLResponse(url: URL(string: "https://test.com/test")!,
                                                    statusCode: 400,
                                                    httpVersion: nil,
                                                    headerFields: [:]),
                                    NSError(domain: "test", code: 42, userInfo: [NSLocalizedDescriptionKey: "Test error"]))
        
        do {
            let _ = try await request.perform(decoding: User.self)
        } catch {
            XCTAssertEqual((error as NSError).code, 42)
        }
    }
}
