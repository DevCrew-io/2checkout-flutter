//
//  UIView+Extension.swift
//  Verifone2CO
//

import Foundation

extension ControlState: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
