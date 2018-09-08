//
//  WebViewController.swift
//  CaterAllenApp
//
//  Created by Mattia Campolese on 08/09/2018.
//  Copyright © 2018 Mattia Campolese. All rights reserved.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {
    
    var accountModel: AccountModel?

    @IBOutlet private var webView: WKWebView!
    private let userContentController = WKUserContentController()
    
    override func loadView() {
        super.loadView()
        initializeWebView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let accountModel = accountModel else {
            presentAlert("No account model passed.")
            return
        }

        load(url: accountModel.baseURL)
    }
    
    private func initializeWebView() {
        let config = WKWebViewConfiguration()
        
        ScriptScenario.allCases.forEach {
            userContentController.add(self, name: $0.rawValue)
        }
        
        userContentController.addUserScript(makeScript(ScriptScenario.scripts))
        
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
    
    private func load(url: String) {
        guard let url = URL(string: url) else {
            assertionFailure("Loading wrong url")
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    
}

// MARK: - WKScriptMessageHandler
extension WebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        processMessage(message, accountModel: accountModel!)
    }
    
    private func processMessage(_ message: WKScriptMessage, accountModel: AccountModel) {
        guard let scriptScenario = ScriptScenario(rawValue: message.name) else {
            presentAlert("Wrong scenario")
            return
        }
        
        switch scriptScenario {
        case .preLogin:
            let pacStrings = extractPositionStrings(message.body as! String, from: accountModel.pac)
            let evaluatedScript = "performLogin('\(accountModel.customerID)', '\(pacStrings[0])', '\(pacStrings[1])', '\(pacStrings[2])')"
            evaluateScript(evaluatedScript)
            break
        case .preSecondStepAuth:
            let passwordString = extractPositionStrings(message.body as! String, from: accountModel.password)
            let evaluatedScript = "performSecondStep('\(passwordString[0])', '\(passwordString[1])', '\(passwordString[2])')"
            evaluateScript(evaluatedScript)
            break
        case .importantInfo:
            let evaluatedScript = "performContinueImportantInfo()"
            evaluateScript(evaluatedScript)
        case .showTransactions:
            let evaluatedScript = "showTransactions('\(accountModel.defaultAccountNumber)')"
            evaluateScript(evaluatedScript)
            break
        default:
            presentAlert(message.body)
            break
        }

    }
    
    private func extractPositionStrings(_ rawMessage: String, from source: String) -> [String] {
        return rawMessage.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap {
                Int($0)
            }
            .map {
                String(source[source.index(source.startIndex, offsetBy: $0 - 1)])
        }
    }
    
    private func evaluateScript(_ script: String) {
        print("+++ Evaluating \(script) +++")
        webView.evaluateJavaScript(script) { (res, error) in
            if let res = res {
                print(res)
            }
        }
    }
    
}
