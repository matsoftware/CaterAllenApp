//
//  WebViewPresenter.swift
//  CaterAllenApp
//
//  Created by Mattia Campolese on 08/09/2018.
//  Copyright © 2018 Mattia Campolese. All rights reserved.
//

import Foundation

protocol WebViewEventHandler {
    
    func viewDidLoad()
    
    func webViewMessageReceived(name: String, body: String) throws
    
}

enum ProcessorError: Error {
    case wrongScenario
    case genericError(message: String)
}

final class WebViewPresenter: WebViewEventHandler {

    private let accountModel: AccountModel
    private weak var view: WebView!
    
    init(accountModel: AccountModel, view: WebView) {
        self.accountModel = accountModel
        self.view = view
    }
    
    func viewDidLoad() {
        view.initializeWebView(events: ScriptScenario.allCases.map { $0.rawValue },
                               injectedScript: injectedScript)
        view.load(URL(string: accountModel.baseURL)!)
    }
    
    func webViewMessageReceived(name: String, body: String) throws {

        guard let scriptScenario = ScriptScenario(rawValue: name) else {
            throw ProcessorError.wrongScenario
        }
        
        let script: String
        
        switch scriptScenario {
        case .preLogin:
            script = "performLoginFirstStep('\(accountModel.customerID)')"
            break
        case .preSecondStepAuth:
            // PAC and Password are in the same message. Stripping the string with a custom separator.
            let composedPacAndPassword = body.components(separatedBy: CharacterSet(charactersIn: pacPasswordSeparator))
            let pacStrings = extractPositionStrings(composedPacAndPassword[0], from: accountModel.pac)
            let passwordString = extractPositionStrings(composedPacAndPassword[1], from: accountModel.password)
            script = "performSecondStep('\(pacStrings[0])','\(pacStrings[1])','\(pacStrings[2])','\(passwordString[0])', '\(passwordString[1])', '\(passwordString[2])')"
            break
        case .importantInfo:
            script = "performContinueImportantInfo()"
        case .showTransactions:
            script = "showTransactions('\(accountModel.defaultAccountNumber)')"
            break
        case .error:
            throw ProcessorError.genericError(message: body)
        }
        
        view.evaluateCommand(script: script)
        
    }
    
    private func extractPositionStrings(_ rawMessage: String, from source: String) -> [String] {
        return rawMessage.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }
            .map { String(source[source.index(source.startIndex, offsetBy: $0 - 1)]) }
    }
    
}

// MARK: - Injected Script
extension WebViewPresenter {
    
    private var injectedScript: String {
        
        let common =
        """
            function getElem(xPath) {
                var element = document.evaluate(xPath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
                if (element != null) {
                    return element;
                }
                return null;
            };

            function extrInnerText(element) {
                return (element != null) ? element.innerText : "null";
            }
            
            function appendHiddenField(name, value) {
                var hInput = document.createElement("input");
                hInput.setAttribute("type", "hidden");
                hInput.setAttribute("name", name);
                hInput.setAttribute("value", value);
                return hInput
            }

        """
        
        let eventListeners =
        """
        window.addEventListener("load", function(){
        
            var inputUserName = getElem('.//*[@id="user_id"]/h1');
            var inputUserNameText = extrInnerText(inputUserName)
            if (inputUserName != null) {
                webkit.messageHandlers.\(ScriptScenario.preLogin.rawValue).postMessage(inputUserNameText);
            }
        
            var rawPac = getElem('(.//div[@id="tran_confirm"]//span)[1]');
            var rawPassword = getElem('(.//div[@id="tran_confirm"]//span)[2]');
            if ((rawPassword != null) && (rawPac != null)) {
                var composedValue = rawPac.innerText + "\(pacPasswordSeparator)" + rawPassword.innerText;
                webkit.messageHandlers.\(ScriptScenario.preSecondStepAuth.rawValue).postMessage(composedValue);
            }
        
            var importantInfoPathStr = './/h1["Important Information"]';
            var importantInfoPath = getElem(importantInfoPathStr);
            var importantInfoText = extrInnerText(importantInfoPath)
            if (importantInfoText != inputUserNameText) {
                webkit.messageHandlers.\(ScriptScenario.importantInfo.rawValue).postMessage(importantInfoText);
            }
        
            var myPortfolioPath = './/h1["My Portfolio"]';
            var myPortfolio = getElem(myPortfolioPath);
            if (myPortfolio.innerText == "My Portfolio") {
                webkit.messageHandlers.\(ScriptScenario.showTransactions.rawValue).postMessage(myPortfolioPath);
            }
        
            var rawError = getElem('.//div[@id="errRed"]')
            if (typeof rawError.innerText === 'string' && rawError.innerText.length > 0){
                webkit.messageHandlers.\(ScriptScenario.error.rawValue).postMessage(rawError.innerText);
            }
        
        });
        """
        
        let performLoginFirstStep =
        """

            function empty() {
            }

            function submitAction() {
                document.Logon1.submit();
                return false;
            }

            function performLoginFirstStep(custId) {
                var inputCustId = getElem('.//input[@id="iUserName"]');
                inputCustId.value = custId;
                var confirmButton = getElem('.//input[@id="butt"]');
                confirmButton.onclick = submitAction;
                submitAction()
                confirmButton.onclick = empty
            }
        """
        
        let performSecondStep =
        """

            function performSecondStep(PAC1, PAC2, PAC3, PASSW1, PASSW2, PASSW3) {
                var inputPAC1 = getElem('.//input[@id="ipos1"]');
                var inputPAC2 = getElem('.//input[@id="ipos2"]');
                var inputPAC3 = getElem('.//input[@id="ipos3"]');

                var inputPASSW1 = getElem('.//input[@id="iPasspos1"]');
                var inputPASSW2 = getElem('.//input[@id="iPasspos2"]');
                var inputPASSW3 = getElem('.//input[@id="iPasspos3"]');

                inputPAC1.value = PAC1;
                inputPAC2.value = PAC2;
                inputPAC3.value = PAC3;

                inputPASSW1.value = PASSW1;
                inputPASSW2.value = PASSW2;
                inputPASSW3.value = PASSW3;

                document.Logon2.submit()

            }

        """
        
        let performImportantInfo =
        """

            function continueImportantInfoClick() {
                var noticeForm = document.notice;
                var hField = appendHiddenField("Menu", "Continue");
                noticeForm.appendChild(hField);
                noticeForm.submit()
                return false
            }

            function performContinueImportantInfo() {
                var continueButton = getElem('.//input[@id="continue_butt"]');
                if (continueButton != null) {
                    continueImportantInfoClick()
                }
            }
        """
        
        let performShowTransactions =
        """

            function showTransactions(account) {
                var profileForm = document.Profile;
                var hField = appendHiddenField("Acc", account);
                profileForm.appendChild(hField);
                profileForm.submit()
                return false
            }
            

        """
        
        return [common,
                eventListeners,
                performLoginFirstStep,
                performSecondStep,
                performImportantInfo,
                performShowTransactions].joined(separator: "\n")
    }

    
}
