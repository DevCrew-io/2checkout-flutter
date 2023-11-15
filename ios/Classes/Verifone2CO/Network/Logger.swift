//
//  NetworkLogger.swift
//  Verifone2CO
//

import Foundation

struct Logger { }

extension Logger {
    static func request(request: URLRequest) {
        #if DEBUG
        print("\n- - - - - - -REQUEST STARTTED- - - - - -")

        let urlString = request.url?.absoluteString ?? ""
        var logStr = "\(urlString)\n"
        for (key, value) in request.allHTTPHeaderFields ?? [:] {
            logStr += "\(key): \(value) "
        }
        if let body = request.httpBody {
            logStr += "\n\(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
        }
        print(logStr)
        #endif
    }

    static func response(data: Data?, error: Error?) {
        #if DEBUG
        if data == nil && error == nil { return }
        print("\n- - - - - - -RESPONSE- - - - - -")
        if let error = error {
            debugPrint(error)
        }
        if let data = data {
            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                debugPrint(json)
            } else {
                let dataStr = String(decoding: data, as: UTF8.self)
                debugPrint(dataStr)
            }
        }
        #endif
    }
}
