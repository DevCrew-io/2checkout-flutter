//
//  Token.swift
//  Verifone2CO
//

import Foundation

public struct Token: Codable {
    let token: String
}

public struct ErrorTokenGenerate: Codable {
    let status: Int?
    let code, detail: String?
}
