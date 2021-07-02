//
//  NetworkError.swift
//
//
//  Created by Andrea Sacerdoti on 17/12/20.
//

import Foundation

/// A specialized error for network purposes.
public enum NetworkError: LocalizedError {

  /// A generic network error.
  case generic

  /// An error identifying the 400 HTTP status code.
  case badRequest

  /// An error identifying the 401 HTTP status code.
  case unauthorized

  /// An error identifying the 403 HTTP status code.
  case forbidden

  /// An error identifying the 404 HTTP status code.
  case notFound

  /// An error identifying the 500 HTTP status code.
  case internalServerError

  /// An error including a description provided by the backend.
  case withDescription(String)

  public var errorDescription: String? {
    switch self {
    case .generic:
      return NSLocalizedString("Generic error.", comment: "")
    case .badRequest:
      return NSLocalizedString("Bad request.", comment: "")
    case .unauthorized:
      return NSLocalizedString("Unauthorized.", comment: "")
    case .forbidden:
      return NSLocalizedString("Access denied.", comment: "")
    case .notFound:
      return NSLocalizedString("Resource not found.", comment: "")
    case .internalServerError:
      return NSLocalizedString("Internal server error.", comment: "")
    case .withDescription(let description):
      return NSLocalizedString(description, comment: "")
    }
  }

  /// Returns a NetworkError identifying a given HTTP error.
  /// - Parameter statusCode: The given HTTP status code.
  /// - Returns: A NetworkError identified by the given status code.
  public static func identifying(statusCode: Int) -> NetworkError {
    switch statusCode {
    case 400:
      return NetworkError.badRequest
    case 401:
      return NetworkError.unauthorized
    case 403:
      return NetworkError.forbidden
    case 404:
      return NetworkError.notFound
    case 500:
      return NetworkError.internalServerError
    default:
      return NetworkError.generic
    }
  }
}

// MARK: -
extension NetworkError: Equatable {
}
