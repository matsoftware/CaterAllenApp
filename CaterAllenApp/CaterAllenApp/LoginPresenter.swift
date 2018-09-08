//
//  LoginPresenter.swift
//  CaterAllenApp
//
//  Created by Mattia Campolese on 08/09/2018.
//  Copyright © 2018 Mattia Campolese. All rights reserved.
//

import Foundation

protocol LoginViewHandler {
    
    func viewDidLoad()
    
    func loginTap(model: AccountModel)
    
}

final class LoginPresenter: LoginViewHandler {
    
    weak var view: LoginView!
    
    func viewDidLoad() {
        
    }
    
    func loginTap(model: AccountModel) {
        guard model.isValid else {
            view.showError()
            return
        }
        
        view.navigateToAccount(model: model)
        
    }
    
}
