//
//  AppDelegate.swift
//  DrawingApp
//
//  Created by Ryan Ackermann on 11/6/14.
//  Copyright (c) 2014 Ryan Ackermann. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{

    var window: UIWindow?
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let audioEngine = RAAudioEngine()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        application.applicationSupportsShakeToEdit = true;
        
        return true
    }

    func applicationDidEnterBackground(application: UIApplication)
    {
        notificationCenter.postNotificationName("NOTIFICATION_SHUT_DOWN_ADVERTISER", object: self)
    }

    func applicationDidBecomeActive(application: UIApplication)
    {
        notificationCenter.postNotificationName("NOTIFICATION_START_ADVERTISER", object: self)
    }
    
    func applicationWillResignActive(application: UIApplication) { }
    
    func applicationWillEnterForeground(application: UIApplication) { }

    func applicationWillTerminate(application: UIApplication) { }
}

