//
//  LoginViewController.swift
//  CaterAllenApp
//
//  Created by Mattia Campolese on 08/09/2018.
//  Copyright © 2018 Mattia Campolese. All rights reserved.
//

import UIKit

protocol LoginView: class {
    
    func populateFields(model: AccountModel)
    
    func showError()
        
    func navigateToAccount(model: AccountModel)
    
}

final class LoginViewController: UIViewController {

    var eventHandler = LoginPresenter()
    
    private let goToAccount = "goToAccount"
    @IBOutlet private weak var txtCustomerID: UITextField!
    @IBOutlet private weak var txtPAC: UITextField!
    @IBOutlet private weak var txtPassword: UITextField!
    @IBOutlet private weak var txtAccountNumber: UITextField!
    @IBOutlet private weak var btnLogin: UIButton!
    
    @IBAction func loginAction(_ sender: Any) {
        loginTap()
    }
    
    override func viewDidLoad() {
        eventHandler.view = self
        super.viewDidLoad()
        eventHandler.viewDidLoad()
    }
    
    // MARK: - Navigation

    func loginTap() {
        let model = AccountModel(customerID: txtCustomerID.text ?? "",
                                 pac: txtPAC.text ?? "",
                                 password: txtPassword.text ?? "",
                                 defaultAccountNumber: txtAccountNumber.text ?? "")
        eventHandler.loginTap(model: model)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let webViewController = segue.destination as? WebViewController, let model = sender as? AccountModel else {
            return
        }
        
        let presenter = WebViewPresenter(accountModel: model, view: webViewController)
        webViewController.eventHandler = presenter
    }
    
}

// MARK: - LoginView
extension LoginViewController: LoginView {
    
    func populateFields(model: AccountModel) {
        txtCustomerID.text = model.customerID
        txtPAC.text = model.pac
        txtPassword.text = model.password
        txtAccountNumber.text = model.defaultAccountNumber
    }
    
    func showError() {
        let alert = UIAlertController(title: "Auth error", message: "Some fields are missing or invalid.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func navigateToAccount(model: AccountModel) {
       performSegue(withIdentifier: goToAccount, sender: model)
    }
}
