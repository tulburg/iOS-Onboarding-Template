//
//  ViewController.swift
//  clove
//
//  Created by Tolu Oluwagbemi on 07/03/2023.
//

import UIKit

class ViewController: UIViewController {
    
//    var user: User?
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        user = DB.UserRecord()
    }
    
    var delegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    var safeAreaInset: UIEdgeInsets? {
        get {
            let delegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
            return delegate.window?.safeAreaInsets
        }
    }
    
    func ButtonXL(_ text: String, action: Selector) -> UIButton {
        let button = UIButton(text, font: UIFont.systemFont(ofSize: 18, weight: .bold))
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
