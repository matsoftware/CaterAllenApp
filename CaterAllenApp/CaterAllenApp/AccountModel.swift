//
//  AccountModel.swift
//  CaterAllenApp
//
//  Created by Mattia Campolese on 08/09/2018.
//  Copyright © 2018 Mattia Campolese. All rights reserved.
//

import Foundation

struct AccountModel {
    
    let baseURL = "https://www.caterallenonline.co.uk"

    var customerID: String
    var pac: String
    var password: String
    var defaultAccountNumber: String
    
    init(customerID: String, pac: String, password: String, defaultAccountNumber: String) {
        self.customerID = customerID
        self.pac = pac
        self.password = password
        self.defaultAccountNumber = defaultAccountNumber
    }
    
}
