//
//  RequestConfigurationHolder.swift
//  
//
//  Created by Andrea Sacerdoti on 27/01/2020.
//

import Foundation

public class RequestConfigurationHolder {
  public static var shared = RequestConfigurationHolder()

  var configuration: RequestConfiguration

  init(configuration: RequestConfiguration = DefaultRequestConfiguration()) {
    self.configuration = configuration
  }
}
