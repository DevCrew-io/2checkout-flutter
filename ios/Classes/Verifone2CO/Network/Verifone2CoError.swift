//
//  ApiEnvironment.swift
//  Verifone2CO
//

import Foundation

public enum Verifone2CoError: Error, Equatable {
    /// Missing required params for sdk
    case requiredParams(String?)
    /// No data received from the server.
    case noData
    /// The server response was invalid (unexpected format).
    case invalidResponse(String?)
    /// The request was rejected: 400-499
    case badRequest(String?)
    /// Encoutered a server error.
    case serverError(String?)
    /// There was an error parsing the data.
    case parseError(String?)
    /// Unknown error.
    case unknown
}

extension Verifone2CoError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .requiredParams(let error):
            let format = NSLocalizedString(
                "Missing %@",
                comment: ""
            )
            return String(format: format, error ?? "")
        case .noData:
            return NSLocalizedString(
                "No Data",
                comment: ""
            )
        case .invalidResponse(let error):
            let format = NSLocalizedString(
                "Invalid response: %@",
                comment: ""
            )
            return String(format: format, error ?? "")
        case .badRequest(let error):
            let format = NSLocalizedString(
                "Bad request: %@",
                comment: ""
            )
            return String(format: format, error ?? "")
        case .serverError(let error):
            let format = NSLocalizedString(
                "Server error: %@",
                comment: ""
            )
            return String(format: format, error ?? "")
        case .parseError(let error):
            let format = NSLocalizedString(
                "Parse error: %@",
                comment: ""
            )
            return String(format: format, error ?? "")
        case .unknown:
            return NSLocalizedString(
                "Unknown error",
                comment: ""
            )
        }
    }
}
