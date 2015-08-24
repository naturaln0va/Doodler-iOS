//
//  Created by Ryan Ackermann on 8/6/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

func delay(delay: Double, closure: ()->())
{
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func isIPad() -> Bool
{
    return UIDevice.currentDevice().userInterfaceIdiom == .Pad
}

func isIOS8OrLater() -> Bool
{
    return NSString(string: UIDevice.currentDevice().systemVersion).floatValue >= 8.0
}