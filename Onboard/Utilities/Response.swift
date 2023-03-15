//
//  Objects.swift
//  Town SQ
//
//  Created by Tolu Oluwagbemi on 21/12/2022.
//  Copyright © 2022 Tolu Oluwagbemi. All rights reserved.
//
import Foundation

class Response<T: ResponseProtocol> {
    var code: Int?
    var status: Int?
    var message: String?
    var error: String?
    var data: T?
    
    init(_ dict: NSDictionary) {
        code = dict.int("code")
        status = dict.int("status")
        message = dict.string("message")
        data = dict.type("data")
        error = dict.string("error")
    }
}

class DataType {
    class Basic: ResponseProtocol {
        required init(_ value: String) {}
    }
    class Login: ResponseProtocol {
        var token: String?
        var id: String?
        required init(_ dict: NSDictionary) {
            token = dict.string("token")
            id = dict.string("id")
        }
    }
}


fileprivate extension NSDictionary {
    func string(_ key: String) -> String? {
        if let value = self[key] as? String {
            return value
        }
        return nil
    }
    
    func date(_ key: String) -> Date? {
        if let value = self[key] as? String {
            return Date.from(string: value)
        }
        return nil
    }
    
    func int(_ key: String) -> Int? {
        if let value = self[key] as? Int {
            return value
        }
        return nil
    }
    
    func type<T: ResponseProtocol>(_ key: String) -> T? {
        if let value = self[key] as? NSDictionary {
            return T.init(value)
        }
        if let stringValue = self[key] as? String {
            return T.init(stringValue)
        }
        return nil
    }
}

@objc protocol ResponseProtocol {
    init(_ dict: NSDictionary)
    init(_ value: String)
}
