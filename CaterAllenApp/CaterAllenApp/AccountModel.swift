//
//  AccountModel.swift
//  CaterAllenApp
//
//  Created by Mattia Campolese on 08/09/2018.
//  Copyright © 2018 Mattia Campolese. All rights reserved.
//

import Foundation

enum AccountKeys: String, CaseIterable {
    case customerID
    case pac
    case password
    case defaultAccountNumber
}

struct AccountModel: Equatable {
    
    enum KeyPathError: Error {
        case missingKeypath
    }
    
    let baseURL = "https://www.caterallenonline.co.uk"
    
    var customerID: String = ""
    var pac: String = ""
    var password: String = ""
    var defaultAccountNumber: String = ""
    
    var isValid: Bool {
        return !self.customerID.isEmpty &&
            self.pac.count == 6 &&
            !self.password.isEmpty &&
            !self.defaultAccountNumber.isEmpty
    }
    
    static func keyPath(from str: String) throws -> WritableKeyPath<AccountModel, String> {
        guard let key = AccountKeys(rawValue: str) else {
            throw KeyPathError.missingKeypath
        }
        
        switch key {
        case .customerID:
            return \AccountModel.customerID
        case .pac:
            return \AccountModel.pac
        case .password:
            return \AccountModel.password
        case .defaultAccountNumber:
            return \AccountModel.defaultAccountNumber
        }
        
    }
    
}
