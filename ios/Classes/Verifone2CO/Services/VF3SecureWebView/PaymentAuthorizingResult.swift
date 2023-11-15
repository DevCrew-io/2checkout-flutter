//
//  PaymentAuthorizingResult.swift
//  Verifone2CO
//

import Foundation

public final class PaymentAuthorizingResult: NSObject {
    public let queryStringDictionary: NSMutableDictionary?
    public let redirectedUrl: URL

    public init(redirectedUrl: URL, queryStringDictionary: NSMutableDictionary?) {
        self.redirectedUrl = redirectedUrl
        self.queryStringDictionary = queryStringDictionary
    }
}
