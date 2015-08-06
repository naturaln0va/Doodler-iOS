//
//  Created by Ryan Ackermann on 8/6/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import Foundation

func delay(delay: Double, closure: ()->())
{
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}