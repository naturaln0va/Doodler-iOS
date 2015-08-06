//
//  Created by Ryan Ackermann on 7/7/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

extension UIView
{
    func imageByCapturing() -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, 0.0)
        
        self.drawViewHierarchyInRect(CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: bounds.size.height), afterScreenUpdates: false)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}