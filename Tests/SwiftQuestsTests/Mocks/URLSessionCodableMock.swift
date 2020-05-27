//
//  URLSessionCodableMock.swift
//  
//
//  Created by Andrea Sacerdoti on 06/02/2020.
//

import Foundation

class URLSessionCodableMock: URLSessionMock {
  override init() {
    super.init()
    let user = User()
    user.username = "test"
    self.data = try? JSONEncoder().encode(user)
  }
}
