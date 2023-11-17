//
//  RequestParameters.swift
//  Verifone2CO
//
//  Created by Oraz Atakishiyev on 31.01.2023.
//

import Foundation

public typealias RequestHeaders = [String: String]
public typealias RequestParameters = [String : Any?]

public enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
}
