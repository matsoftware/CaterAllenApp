//
//  WebViewController.swift
//  CaterAllenApp
//
//  Created by Mattia Campolese on 08/09/2018.
//  Copyright © 2018 Mattia Campolese. All rights reserved.
//

import UIKit
import WebKit

protocol WebView: class {
    
    func initializeWebView(events: [String], injectedScript: String)
    
    func load(_ url: URL)
    
    func evaluateCommand(script: String)

    func showBalance(_ balance: String)
    
}

final class WebViewController: UIViewController {
    
    var eventHandler: WebViewEventHandler!

    @IBOutlet private var webView: WKWebView!
    private let userContentController = WKUserContentController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventHandler.viewDidLoad()
        addReloadButton()
    }
    
    private func makeScript(_ script: String) -> WKUserScript {
        return WKUserScript(
            source: script,
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )
    }
    
    private func presentAlert(_ message: Any) {
        let alert = UIAlertController(title: "Message", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func addReloadButton() {
        let rightButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        navigationItem.setRightBarButton(rightButton, animated: false)
    }
    
    @objc func refresh() {
        webView.reload()
    }
    
}

// MARK: - WKScriptMessageHandler
extension WebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        do {
            try eventHandler.webViewMessageReceived(name: message.name, body: message.body as? String ?? "")
        } catch let error {
            webView.stopLoading()
            navigationController?.popViewController(animated: false)
            presentAlert("Error while communicating with the website (\(error.localizedDescription))")
        }
        
    }
    
}

// MARK: - WebView
extension WebViewController: WebView {

    func showBalance(_ balance: String) {
        title = balance
    }
   
    func initializeWebView(events: [String], injectedScript: String) {
        events.forEach {
            userContentController.add(self, name: $0)
        }
        userContentController.addUserScript(makeScript(injectedScript))
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        
        webView = WKWebView(
            frame: view.bounds,
            configuration: config
        )
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/604.4.7 (KHTML, like Gecko) Version/11.0.2 Safari/604.4.7"
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView!)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

    }
    
    func load(_ url: URL) {
        webView.load(URLRequest(url: url))
    }
    
    func evaluateCommand(script: String) {
        webView.evaluateJavaScript(script) { _, _ in }
    }
    
}
