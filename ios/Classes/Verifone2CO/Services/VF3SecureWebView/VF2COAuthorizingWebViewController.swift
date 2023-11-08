//
//  VF3DSecureWebViewController.swift
//  VerifoneSDK
//

import UIKit
import WebKit

public protocol VF2COAuthorizePaymentControllerDelegate: AnyObject {
    func authorizePaymentViewController(didCompleteAuthorizing result: PaymentAuthorizingResult)
    func authorizePaymentViewControllerDidCancel()
}

public final class VF2COAuthorizePaymentController: Verifone2COPaymentForm {

    private var activityIndicatorView: UIActivityIndicatorView!
    private var titleCardForm: UILabel = UILabel(frame: .zero)
    private var closeButton: UIButton = UIButton(frame: .zero)
    private var edgeInsets = UIEdgeInsets(top: 0, left: 15.0, bottom: 0.0, right: 10.0)

    private(set) var webView: WKWebView!
    private(set) lazy var hTopStackView: UIStackView = {
        let hTopStackView = UIStackView()
        hTopStackView.backgroundColor = UIColor.VF2Co.background
        hTopStackView.axis  = NSLayoutConstraint.Axis.horizontal
        hTopStackView.distribution  = UIStackView.Distribution.equalSpacing
        hTopStackView.alignment = UIStackView.Alignment.center
        hTopStackView.layoutMargins = edgeInsets
        hTopStackView.isLayoutMarginsRelativeArrangement = true
        return hTopStackView
    }()

    public var paymentMethod: PaymentMethodType!
    public var webConfig: VFWebConfig!
    public weak var delegate: VF2COAuthorizePaymentControllerDelegate?

    init(webConfig: VFWebConfig) {
        super.init(nibName: nil, bundle: nil)
        self.webConfig = webConfig
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        initWebView()
        setEventHandlers()
        createViews()
        loadWebview()
    }

    func loadWebview() {
        guard let urlReuqest = self.webConfig.urlReuqest else {
            fatalError("Missing required parameters for webview")
        }
        debugPrint("Initializing auth payment proccess \(webConfig.urlReuqest!.url!)")
        activityIndicatorView.startAnimating()
        webView.load(urlReuqest)
    }

    private func initWebView() {
        self.activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        webView = WKWebView(frame: .zero, configuration: webConfig.webViewConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = UIColor.VF2Co.background
        self.view.backgroundColor = UIColor.VF2Co.background
        view.addSubview(webView)
        webView.uiDelegate = self
        webView.navigationDelegate = self
    }

    private func setEventHandlers() {
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }

    @objc private func close() {
        self.dismiss(animated: true, completion: {
            self.delegate?.authorizePaymentViewControllerDidCancel()
        })
    }

    private func validatePaymentURL(_ url: URL, expectedRedirectURL: [URLComponents]) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }

        return expectedRedirectURL.contains { redirectURLComponents -> Bool in
            return redirectURLComponents.scheme == components.scheme
                && redirectURLComponents.host == components.host
                && components.path.hasPrefix(redirectURLComponents.path)
        }
    }

    public override var panScrollable: UIScrollView? {
        return nil
    }

    public override var longFormHeight: PanModalHeight {
        return .maxHeight
    }

    public override var anchorModalToLongForm: Bool {
        return true
    }

    public override var shouldRoundTopCorners: Bool {
        return true
    }

    public override func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        true
    }

    public var allowsExtendedPanScrolling: Bool {
        return true
    }
}

extension VF2COAuthorizePaymentController: WKNavigationDelegate, WKUIDelegate {

    public func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        self.activityIndicatorView.stopAnimating()
        if !webView.hasOnlySecureContent {
            self.close()
        }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if let url = navigationAction.request.url, validatePaymentURL(url, expectedRedirectURL: webConfig!.expectedRedirectUrl!) {
            debugPrint("Redirected to expected \(url.absoluteString)")
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)

            let dict: NSMutableDictionary = [:]
            for keyVal in components!.queryItems! {
                let name = keyVal.name
                let val = keyVal.value
                dict.setValue(val, forKey: name.lowercased())
            }
            dismiss(animated: true) {
                let result = PaymentAuthorizingResult(redirectedUrl: url, queryStringDictionary: dict)
                self.delegate?.authorizePaymentViewController(didCompleteAuthorizing: result)
                decisionHandler(.cancel)
            }
        } else if let url = navigationAction.request.url, validatePaymentURL(url, expectedRedirectURL: webConfig!.expectedCancelUrl!) {
            debugPrint("Redirected to cancel \(url.absoluteString)")
            close()
            decisionHandler(.cancel)
        } else {
            debugPrint("Redirected to non expected \(navigationAction.request.url?.absoluteString ?? "")")
            decisionHandler(.allow)
        }
       
    }
}

extension VF2COAuthorizePaymentController {
    func createViews() {
        view.addSubview(activityIndicatorView)

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        closeButton.tintColor = UIColor.VF2Co.cardFormLabel
        closeButton.setImage(UIImage(named: "close", in: .module, compatibleWith: nil), for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        // HTOPStack View for title and close button
        hTopStackView.addArrangedSubview(titleCardForm)
        hTopStackView.addArrangedSubview(closeButton)
        hTopStackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(hTopStackView)

        // constraints for top stack view
        NSLayoutConstraint.activate([
            hTopStackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
            hTopStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0),
            hTopStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
            hTopStackView.heightAnchor.constraint(equalToConstant: 40.0)
        ])

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: hTopStackView.bottomAnchor, constant: 0.0),
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),

            activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0.0),
            activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0.0)
        ])
    }
}
