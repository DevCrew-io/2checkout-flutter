//
//  Globals.swift
//  Verifone2CO
//

import UIKit

typealias ControlState = UIControl.State
let KeyboardWillHideFrameNotification: NSNotification.Name = UIResponder.keyboardWillHideNotification
let KeyboardWillShowFrameNotification: NSNotification.Name = UIResponder.keyboardWillShowNotification
let KeyboardWillChangeFrameNotification: NSNotification.Name = UIResponder.keyboardWillChangeFrameNotification
let KeyboardFrameEndUserInfoKey = UIResponder.keyboardFrameEndUserInfoKey
let KeyboardFrameBeginUserInfoKey = UIResponder.keyboardFrameBeginUserInfoKey
let HeaderKeyMerchantCode = "X-2Checkout-MerchantCode"
