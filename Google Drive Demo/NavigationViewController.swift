//
//  NavigationViewController.swift
//  Google Drive Demo
//
//  Created by HaiboZhou on 2021/8/24.
//

import UIKit

class NavigationController: UINavigationController {
    
    var stateManager: StateManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewControllers = viewControllers
        if let viewController = viewControllers[0] as? ViewController {
            viewController.stateManager = self.stateManager
        }
        
    }
    


}
