//
//  UIColor+Extension.swift
//  Verifone2CO
//

import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1) {
            let chars = Array(hex.dropFirst())
            self.init(red: .init(strtoul(String(chars[0...1]), nil, 16))/255,
                      green: .init(strtoul(String(chars[2...3]), nil, 16))/255,
                      blue: .init(strtoul(String(chars[4...5]), nil, 16))/255,
                      alpha: alpha)}
}

extension UIColor {
    public enum VF2Co {
        public static let background: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                    if UITraitCollection.userInterfaceStyle == .dark {
                        return UIColor.systemBackground
                    } else {
                        return UIColor.systemBackground
                    }
                }
            } else {
                return UIColor.white
            }
        }()

        public static let secondaryLabel: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.secondaryLabel
            } else {
                return UIColor.darkGray
            }
        }()

        public static let lightGray: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.systemGray2
            } else {
                return UIColor.lightGray
            }
        }()

        public static let defaultBlackLabelColor: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.label
            } else {
                return UIColor.black
            }
        }()

        public static let secondarySystemBackground: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.secondarySystemBackground
            } else {
                return UIColor.white
            }
        }()

        // MARK: - CARDFORM
        public static let cardFormTextFieldBackground: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                    if UITraitCollection.userInterfaceStyle == .dark {
                        return UIColor.systemBackground
                    } else {
                        return UIColor.white
                    }
                }
            } else {
                return UIColor.white
            }
        }()

        public static let cardFormTextfieldText: UIColor = {
            if #available(iOS 13, *) {
                return UIColor { (traitCollection) -> UIColor in
                    if traitCollection.userInterfaceStyle == .dark {
                        return UIColor(hex: "#D1D1D6")
                    } else {
                        return UIColor(hex: "#364049")
                    }
                }
            } else {
                return UIColor(hex: "#364049")
            }
        }()

        public static let cardFormTextfieldBorder: UIColor = {
            if #available(iOS 13, *) {
                return UIColor { (traitCollection) -> UIColor in
                    if traitCollection.userInterfaceStyle == .dark {
                        return UIColor(hex: "#E4E7ED")
                    } else {
                        return UIColor(hex: "#E4E7ED")
                    }
                }
            } else {
                return UIColor(hex: "#E4E7ED")
            }
        }()

        public static var cardFormTextfieldPlaceholder: UIColor {
            if #available(iOS 13, *) {
                return UIColor { (traitCollection) -> UIColor in
                    if traitCollection.userInterfaceStyle == .dark {
                        return UIColor(hex: "#8E8E93")
                    } else {
                        return UIColor(hex: "#858B9A")
                    }
                }
            } else {
                return UIColor(hex: "#858B9A")
            }
        }

        public static var cardFormLabel: UIColor {
            if #available(iOS 13, *) {
                return UIColor { (traitCollection) -> UIColor in
                    if traitCollection.userInterfaceStyle == .dark {
                        return UIColor(hex: "#8E8E93")
                    } else {
                        return UIColor(hex: "#858B9A")
                    }
                }
            } else {
                return UIColor(hex: "#858B9A")
            }
        }

        public static let cardFormButton = UIColor(hex: "#0A69C7")
    }
}
