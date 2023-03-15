//
//  ViewController.swift
//  clove
//
//  Created by Tolu Oluwagbemi on 07/03/2023.
//

import UIKit

class LoginViewController: ViewController {
    
    var usernameField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .background
        usernameField = UITextField()
        usernameField.placeholder = "Enter username"
        usernameField.font = UIFont.systemFont(ofSize: 24)
        usernameField.textAlignment = .center
        if let username = UserDefaults.standard.string(forKey: "username") {
            usernameField.text = username
        }
        
        let button = ButtonXL("Open messages", action: #selector(openMessages))
        button.setTitleColor(.white, for: .normal)
        let container = UIView()
        container.add().vertical(0).view(usernameField, 44).gap(24).view(button).end(">=0")
        container.constrain(type: .horizontalCenter, usernameField, button)
        view.addSubview(container)
        view.constrain(type: .horizontalCenter, container)
        view.constrain(type: .verticalCenter, container)
        
    }
    
    @objc func openMessages() {
        Api.main.login(username: usernameField.text!) { data, error in
            guard let responseData = data?.json() as? NSDictionary else { return }
            let login = Response<DataType.Login>(responseData)
            if login.status == 200 {
                DispatchQueue.main.async {
                    UserDefaults.standard.set(self.usernameField.text!, forKey: "username")
                    UserDefaults.standard.set((login.data?.id)!, forKey: "id")
                    UserDefaults.standard.set((login.data?.token)!, forKey: Constants.authToken)
                    
                    
                }
            }
        }
    }


}

