//
//  ScriptScenario.swift
//  CaterAllenApp
//
//  Created by Mattia Campolese on 08/09/2018.
//  Copyright © 2018 Mattia Campolese. All rights reserved.
//

import Foundation

enum ScriptScenario: String, CaseIterable {
    case preLogin
    case performLogin
    case preSecondStepAuth
    case importantInfo
    case showTransactions
    case error
    
    static var scripts: String {
        
        let common =
        """
            function getElem(xPath) {
                var element = document.evaluate(xPath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
                if (element != null) {
                    return element;
                }
                return null;
            };

            function appendHiddenField(name, value) {
                var hInput = document.createElement("input");
                hInput.setAttribute("type", "hidden");
                hInput.setAttribute("name", name);
                hInput.setAttribute("value", value);
                return hInput
            }

        """
        
        let returnPacOrPassword =
        """
        window.addEventListener("load", function(){
        var rawPac = getElem('.//div[@id="tran_confirm"]//span')
        if (rawPac != null) {
        webkit.messageHandlers.\(ScriptScenario.preLogin.rawValue).postMessage(rawPac.innerText);
        }
        
        var rawPassword = getElem('.//div[@id="tran_confirm2"]//span')
        if (rawPassword != null) {
        webkit.messageHandlers.\(ScriptScenario.preSecondStepAuth.rawValue).postMessage(rawPassword.innerText);
        }
        
        var rawError = getElem('.//div[@id="errRed"]')
        if (typeof rawError.innerText === 'string' && rawError.innerText.length > 0){
        webkit.messageHandlers.\(ScriptScenario.error.rawValue).postMessage(rawError.innerText);
        }
        
        var importantInfoPath = './/h1["Important Information"]';
        var importantInfoText = getElem(importantInfoPath);
        if (importantInfoText != null) {
        webkit.messageHandlers.\(ScriptScenario.importantInfo.rawValue).postMessage(importantInfoPath);
        }
        
        var myPortfolioPath = './/h1["My Portfolio"]';
        var myPortfolio = getElem(myPortfolioPath);
        if (myPortfolio != null) {
        webkit.messageHandlers.\(ScriptScenario.showTransactions.rawValue).postMessage(myPortfolioPath);
        }
        
        });
        """
        
        let performLogin =
        """

            function empty() {

            }

            function submitAction() {
                document.Logon1.submit();
                return false;
            }

            function performLogin(custId, PAC1, PAC2, PAC3) {
                var inputCustId = getElem('.//input[@id="iCustId"]');
                var inputPAC1 = getElem('.//input[@id="ipos1"]');
                var inputPAC2 = getElem('.//input[@id="ipos2"]');
                var inputPAC3 = getElem('.//input[@id="ipos3"]');
                var confirmButton = getElem('.//input[@id="butt"]');

                inputCustId.value = custId;
                inputPAC1.value = PAC1;
                inputPAC2.value = PAC2;
                inputPAC3.value = PAC3;

                confirmButton.onclick = submitAction;
                submitAction()
                confirmButton.onclick = empty

            }
        """
        
        let performSecondStep =
        """

            function performSecondStep(PASSW1, PASSW2, PASSW3) {
                var inputPASSW1 = getElem('.//input[@id="iPasspos1"]');
                var inputPASSW2 = getElem('.//input[@id="iPasspos2"]');
                var inputPASSW3 = getElem('.//input[@id="iPasspos3"]');

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
                returnPacOrPassword,
                performLogin,
                performSecondStep,
                performImportantInfo,
                performShowTransactions].joined(separator: "\n")
    }
    
}
