//
//  MenuController.swift
//  Whereabouts
//
//  Created by Ryan Ackermann on 5/29/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class MenuController: NSObject
{
    static let sharedController = MenuController()
    
    var presenterViewController: UIViewController?
    
    lazy var canvasVC: CanvasViewController = {
        return CanvasViewController()
    }()
    
    lazy var colorPickerVC: ColorPickerViewController = {
        return ColorPickerViewController()
    }()
    
    override init()
    {
        super.init()
    }
    
    func showInWindow(window: UIWindow)
    {
        presenterViewController = SplashViewController()
        
        window.rootViewController = presenterViewController
        window.makeKeyAndVisible()
        
        if let presenterVC = presenterViewController {
            delay(0.5, {
                presenterVC.presentViewController(self.canvasVC, animated: false, completion: {
                    dispatch_async(dispatch_get_main_queue(), {
                        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
                    })
                })
            })
        }
    }
}
