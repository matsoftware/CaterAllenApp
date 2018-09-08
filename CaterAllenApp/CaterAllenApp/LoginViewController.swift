//
//  LoginViewController.swift
//  CaterAllenApp
//
//  Created by Mattia Campolese on 08/09/2018.
//  Copyright © 2018 Mattia Campolese. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let webViewController = segue.destination as? WebViewController else {
            return
        }
        
        let model = AccountModel(customerID: "",
                                 pac: "",
                                 password: "",
                                 defaultAccountNumber: "")
        
        let presenter = WebViewPresenter(accountModel: model, view: webViewController)
        webViewController.presenter = presenter
    }

}
