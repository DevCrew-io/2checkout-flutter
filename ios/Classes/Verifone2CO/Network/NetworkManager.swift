//
//  NetworkManager.swift
//  Verifone2CO
//

import Foundation

struct NetworkManager {
    private let router = Router(baseURL: "https://2pay-api.2checkout.com/api/v1/")

    func createToken(headers: RequestHeaders, params: [String: Any?], completion: @escaping (_ token: Token?,_ error: Error?) -> Void) {
        router.request(TwoPayEndpoint.createToken(headers: headers, paramters: params)) { response, error in
            completion(response, error)
        }
    }
    
    
}
