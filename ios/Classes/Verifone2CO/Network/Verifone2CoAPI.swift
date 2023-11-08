//
//  Verifone2CoAPI.swift
//  Verifone2CO
//

import Foundation

enum TwoPayEndpoint {
    case createToken(headers: RequestHeaders, paramters: [String: Any?])
}

extension TwoPayEndpoint: ApiEndPoint {

    var headers: RequestHeaders {
        switch self {
        case .createToken(let headers, _):
            return headers
        }
    }

    var path: String {
        switch self {
        case .createToken:
            return "tokens"
        }
    }

    var method: RequestMethod {
        switch self {
        case .createToken:
            return .post
        }
    }

    var parameters: RequestParameters? {
        switch self {
        case .createToken(_, let parameters):
            return parameters
        }
    }
}
