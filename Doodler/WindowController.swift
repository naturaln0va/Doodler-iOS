//
//  Created by Ryan Ackermann on 11/6/14.
//  Copyright (c) 2014 Ryan Ackermann. All rights reserved.
//

import UIKit

@UIApplicationMain
class WindowController: UIResponder, UIApplicationDelegate
{

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        application.applicationSupportsShakeToEdit = true;
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        if let window = window {
            MenuController.sharedController.showInWindow(window)
        }
        
        return true
    }
}

