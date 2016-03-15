//
//  Created by Ryan Ackermann on 5/29/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class RHANavigationViewController: UINavigationController
{

    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return .LightContent
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationBar.barTintColor = RHAColorController.barMainColor
        navigationBar.tintColor = RHAColorController.barTintColor
        navigationBar.translucent = false
        
        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: RHAColorController.barTintColor
        ]
    }
}
