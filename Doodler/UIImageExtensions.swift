//
//  Created by Ryan Ackermann on 8/6/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

extension UIImage
{
    class func imageOfSize(size: CGSize, ofColor color: UIColor) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        color.set()
        UIRectFill(CGRectMake(0, 0, size.width, size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}