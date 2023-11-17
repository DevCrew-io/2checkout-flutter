//
//  BaseFormViewController.swift
//  Verifone2CO
//

import UIKit

public class BaseFormViewController: UIViewController, PanModalPresentable {
    var isKeyboardShowed: Bool = false
    var keyboardFrame: CGRect? = .zero

    public override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow(_:)), name: KeyboardWillShowFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide(_:)), name: KeyboardWillHideFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillChangeFrame(_:)), name: KeyboardWillChangeFrameNotification, object: nil)
    }

    @objc internal func onKeyboardWillShow(_ notification: Notification) {
        isKeyboardShowed = true
        keyboardFrame = (notification.userInfo?[KeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
    }

    @objc internal func onKeyboardWillHide(_ notification: Notification) {
        isKeyboardShowed = false
        keyboardFrame = .zero
    }

    @objc internal func onKeyboardWillChangeFrame(_ notification: Notification) {
        keyboardFrame = (notification.userInfo?[KeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    // MARK: - Pan Modal Presentable

    public var panScrollable: UIScrollView? {
        return nil
    }

    public var longFormHeight: PanModalHeight {
        let height: CGFloat = 300.0
        return .contentHeight(height)
    }

    public var anchorModalToLongForm: Bool {
        return false
    }

    public var shouldRoundTopCorners: Bool {
        return true
    }

    public func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        true
    }

    public var allowsDragToDismiss: Bool {
        return false
    }

    public var allowsTapToDismiss: Bool {
        return false
    }

    public var transitionDuration: Double {
        return 0.4
    }

    public var springDamping: CGFloat {
        return 0.8
    }

    public func panModalWillDismiss() { }
}
