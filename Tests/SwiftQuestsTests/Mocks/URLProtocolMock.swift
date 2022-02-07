//
//  URLProtocolMock.swift
//  
//
//  Created by Andrea Sacerdoti on 05/02/2020.
//

import Foundation

class URLProtocolMock: URLProtocol {
    static var response: (data: Data?, response: URLResponse?, error: Error?)?
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        if let (data, response, error) = URLProtocolMock.response {
            
            if let response = response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
    }
}
