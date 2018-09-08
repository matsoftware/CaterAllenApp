//
//  LoginInteractor.swift
//  CaterAllenApp
//
//  Created by Mattia Campolese on 08/09/2018.
//  Copyright © 2018 Mattia Campolese. All rights reserved.
//

import Foundation

protocol LoginInteractorInterface {
    
    func readValues()
    
    func store(model: AccountModel)
    
    var existingModel: AccountModel? { get }
    
}

final class LoginInteractor: LoginInteractorInterface {
    
    private let service = "CaterAllenApp"
    
    var existingModel: AccountModel?

    // MARK: - KeyChain access
    
    func readValues() {
        existingModel = readStoredValues()
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
    
    func store(model: AccountModel) {
        guard model != existingModel else {
            return
        }
        
        do {
            try AccountKeys.allCases.forEach {
                let keyPath = try AccountModel.keyPath(from: $0.rawValue)
                let item = KeychainPasswordItem(service: service, account: $0.rawValue)
                try item.savePassword(model[keyPath: keyPath])
            }
        } catch {
            assertionFailure("Cannot store login data.")
        }
    }
    
    // MARK: - Biometrics
    
}
