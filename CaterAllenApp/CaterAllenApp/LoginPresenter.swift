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
    private let interactor: LoginInteractorInterface
    
    init(interactor: LoginInteractorInterface = LoginInteractor()) {
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        interactor.readValues()
        if let existingModel = interactor.existingModel {
            view.populateFields(model: existingModel)
        }
    }
    
    func loginTap(model: AccountModel) {
        guard model.isValid else {
            view.showError()
            return
        }
        
        interactor.store(model: model)
        
        interactor.deviceAuthenticationLogin { [weak self] authSucceded in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                if authSucceded {
                    strongSelf.view.navigateToAccount(model: model)
                } else {
                    strongSelf.view.showError()
                }
            }
            
        }
        
    }
    
}

