//
//  Constants.swift
//  Town SQ
//
//  Created by Tolu Oluwagbemi on 21/12/2022.
//  Copyright © 2022 Tolu Oluwagbemi. All rights reserved.
//

import Foundation

struct Constants {
    static let Base = "http://192.168.18.3:3220"
    
    enum Events: String {
        case Login = "login"
        
        func receipt() -> String {
            return self.rawValue + ":receipt"
        }
    }
    static let authToken = "auth-token"
}
