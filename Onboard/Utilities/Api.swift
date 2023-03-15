//
//  Api.swift
//  Town SQ
//
//  Created by Tolu Oluwagbemi on 21/12/2022.
//  Copyright © 2022 Tolu Oluwagbemi. All rights reserved.
//

import UIKit

class Api {
    
    private var parameters: [String: Any]?
    private var path: String!
    private var base: String!
    
    static let main = {
        return Api(base: Constants.Base)
    }()
    
    init(base: String) {
        self.base = base
        path = "/"
        parameters = nil
    }
    
    // MARK: - Call functions
    
    func login(username: String, _ completion: ((_ data: Data?, _ error: Error?) -> Void)?) {
        path = "/login"
        parameters = ["username": username]
        execute(.POST, completion)
    }
    
    // MARK: - Private zone
    
    private func execute(_ method: Method, _ completion: ((_ data: Data?, _ error: Error?) -> Void)?) {
        var request: URLRequest = URLRequest(url: URL(string: (base + path))!)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(UIDevice.current.identifierForVendor!.uuidString, forHTTPHeaderField: "did")
        if let token = UserDefaults.standard.string(forKey: Constants.authToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if parameters != nil {
            if let json = try? JSONSerialization.data(withJSONObject: parameters!) {
                request.httpBody = json
            }
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if completion != nil { completion!(data ?? nil, error)  }
        }
        task.resume()
    }

    enum Method: String {
        case POST
        case GET
        case DELETE
    }
}
