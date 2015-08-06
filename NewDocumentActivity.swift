//
//  Created by Ryan Ackermann on 8/6/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

let kActivityTypeNewDocument = "activityTypeNewDocument"

class NewDocumentActivity: UIActivity
{
    class override func activityCategory() -> UIActivityCategory
    {
        return .Action
    }
    
    override func activityType() -> String?
    {
        return kActivityTypeNewDocument
    }
    
    override func activityTitle() -> String?
    {
        return "New Document"
    }
    
    override func activityImage() -> UIImage?
    {
        return UIImage(named: "new_doc")
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool
    {
        return true
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject])
    {
        
    }
}
