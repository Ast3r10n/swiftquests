//
//  URLSessionDataTaskMock.swift
//  
//
//  Created by Andrea Sacerdoti on 05/02/2020.
//

import Foundation

class URLSessionDataTaskMock: URLSessionDataTask {
  private let completion: () -> Void

  init(completion: @escaping () -> Void) {
    self.completion = completion
  }

  override func resume() {
    completion()
  }
}
