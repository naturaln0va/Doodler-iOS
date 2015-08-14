//
//  Created by Ryan Ackermann on 5/29/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class RHAViewController: UIViewController
{
    init()
    {
        super.init(nibName: NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!, bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
