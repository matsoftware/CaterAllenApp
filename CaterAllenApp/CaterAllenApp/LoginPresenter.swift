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
    
    private var existingModel: AccountModel?
    private let service = "CaterAllenApp"
    
    func viewDidLoad() {
        existingModel = readStoredValues()
        if let existingModel = existingModel {
            view.populateFields(model: existingModel)
        }
    }
    
    func loginTap(model: AccountModel) {
        guard model.isValid else {
            view.showError()
            return
        }
        
        view.navigateToAccount(model: model)
        
    }
    
    private func readStoredValues() -> AccountModel? {
        do {
            let passwordItems = try KeychainPasswordItem.passwordItems(forService: service)
            if passwordItems.isEmpty {
                return nil
            }
            var model = AccountModel()
            try passwordItems.forEach {
                try model[keyPath: AccountModel.keyPath(from: $0.account)] = try $0.readPassword()
            }
            return model
        }
        catch {
            assertionFailure("Error fetching password items - \(error)")
        }
        
        return nil
    }
    
}
