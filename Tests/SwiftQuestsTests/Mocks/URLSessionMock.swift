//
//  URLSessionMock.swift
//  
//
//  Created by Andrea Sacerdoti on 05/02/2020.
//

import Foundation

class URLSessionMock: URLSession {
  var data: Data?
  var response: URLResponse?
  var error: Error?

  override func dataTask(with request: URLRequest,
                         completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    URLSessionDataTaskMock {
      completionHandler(self.data, self.response, self.error)
    }
  }
}
