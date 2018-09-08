//
//  Utils.swift
//  CaterAllenApp
//
//  Created by Mattia Campolese on 08/09/2018.
//  Copyright © 2018 Mattia Campolese. All rights reserved.
//

import Foundation
import WebKit

// MARK: - WebKit

func makeScript(_ script: String) -> WKUserScript {
    return WKUserScript(
        source: script,
        injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
        forMainFrameOnly: true
    )
}

// MARK: - UIViewController

extension UIViewController {
    
    func presentAlert(_ message: Any) {
        let alert = UIAlertController(title: "Message", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
