//
//  RequestConfigurationHolder.swift
//  
//
//  Created by Andrea Sacerdoti on 27/01/2020.
//

import Foundation

/// A holder for a `RequestConfiguration` object to be used by `Request`s by default.
public class RequestConfigurationHolder {

  // MARK: - Public Properties
  /// The holder singleton instance.
  public static var shared = RequestConfigurationHolder()

  // MARK: - Internal Properties
  /// The configuration assigned to the holder.
  var configuration: RequestConfiguration

  // MARK: - Internal Methods
  /// Creates a holder object, assigning the specified configuration.
  ///
  /// If no configuration is passed as an argument, a default configuration is used.
  /// - Parameter configuration: A `RequestConfiguration` to assign to the holder.
  init(configuration: RequestConfiguration = DefaultRequestConfiguration()) {
    self.configuration = configuration
  }
}
