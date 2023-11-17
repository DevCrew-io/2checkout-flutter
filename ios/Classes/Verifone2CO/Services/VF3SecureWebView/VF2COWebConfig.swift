//
//  VF3DSecureWebViewModal.swift
//  VerifoneSDK
//

import WebKit

public final class VFWebConfig {
    let url: String!
    let params: [String: Any]!
    let httpMethod: String!
    let expectedRedirectUrl: [URLComponents]!
    let expectedCancelUrl: [URLComponents]!

    var urlReuqest: URLRequest? {
        guard let url = URL(string: self.url) else {
            return nil
        }
        var components = URLComponents(string: url.absoluteString)!
        guard !self.params.isEmpty else {
            debugPrint("Missing required parameters")
            return nil
        }
        components.queryItems = [URLQueryItem]()
        for (key, value) in params {
            let queryItem = URLQueryItem(name: key, value: value as? String)
            components.queryItems!.append(queryItem)
        }
        var request = URLRequest(url: components.url!)
        request.httpMethod = httpMethod
        request.allHTTPHeaderFields = ["Content-Type": "x-www-form-urlencoded"]
        return request
    }

    var webViewConfiguration: WKWebViewConfiguration {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        return configuration
    }

    public init(url: String, parameters: [String: Any] = [:], expectedRedirectUrl: [URLComponents], expectedCancelUrl: [URLComponents], httpMethod: String? = "GET") {
        self.url = url
        self.params = parameters
        self.httpMethod = httpMethod
        self.expectedRedirectUrl = expectedRedirectUrl
        self.expectedCancelUrl = expectedCancelUrl
    }
}
