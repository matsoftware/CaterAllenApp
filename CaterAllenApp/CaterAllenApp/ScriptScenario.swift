//
//  ScriptScenario.swift
//  CaterAllenApp
//
//  Created by Mattia Campolese on 08/09/2018.
//  Copyright © 2018 Mattia Campolese. All rights reserved.
//

import Foundation

let pacPasswordSeparator = "|"

enum ScriptScenario: String, CaseIterable {
    case preLogin
    case preSecondStepAuth
    case importantInfo
    case showTransactions
    case error
}
