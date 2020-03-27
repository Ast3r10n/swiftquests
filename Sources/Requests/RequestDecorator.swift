//
//  RequestDecorator.swift
//  
//
//  Created by Andrea Sacerdoti on 27/03/2020.
//

import Foundation

/// Implemented by decorators to allow `Request` overrides.
public protocol RequestDecorator: AbstractRequest {

  /// The `AbstractRequest` to decorate.
  var request: AbstractRequest { get set }
}
