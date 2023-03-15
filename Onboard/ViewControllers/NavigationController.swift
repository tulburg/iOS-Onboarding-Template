//
//  NavigationController.swift
//  clove
//
//  Created by Tolu Oluwagbemi on 07/03/2023.
//

import UIKit


class NavigationController: UINavigationController {
    
    var appearance: UINavigationBarAppearance!
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.view.backgroundColor = UIColor.background
        
        appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.blackWhite]
        appearance.backgroundColor = UIColor.background
        appearance.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor: UIColor.blackWhite
        ]
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func hideTopBar() {
        appearance.shadowImage = UIImage(color: UIColor.clear)
        appearance.backgroundColor = UIColor.clear
        appearance.backgroundImage = UIImage()
        appearance.configureWithTransparentBackground()
        
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.compactAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
        self.navigationBar.isTranslucent = true
    }
    
    func showTopBar() {
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.background
        
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.compactAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
        self.navigationBar.isTranslucent = false
    }
}

