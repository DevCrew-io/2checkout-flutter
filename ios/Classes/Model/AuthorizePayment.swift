//
//  AuthorizePayment.swift
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//

import Foundation

class AuthorizePayment {
    static let shared = AuthorizePayment()
    
    var url: String
    var parameters: [String : Any]
    var successReturnUrl: String
    var cancelReturnUrl: String
    
    private init() {
        self.url = ""
        self.parameters = [:]
        self.successReturnUrl = ""
        self.cancelReturnUrl = ""
    }
    
    func fromMap(_ arguments: [String: Any]) {
        self.url = arguments["url"] as? String ?? ""
        self.parameters = arguments["parameters"] as? [String : Any] ?? [:]
        self.successReturnUrl = arguments["successReturnUrl"] as? String ?? ""
        self.cancelReturnUrl = arguments["cancelReturnUrl"] as? String ?? ""
        
        if let url = URL(string: url), parameters.isEmpty {
            self.parameters = url.queryParameters ?? [:]
        }
    }
    
}

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
