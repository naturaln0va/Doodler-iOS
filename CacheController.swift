//
//  Created by Ryan Ackermann on 8/14/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class CacheController: NSObject
{
    static let sharedController = CacheController()
    
    private(set) var cache = NSCache()
    private(set) var indexForAdding = 0
    private(set) var indexForRetrieving = 0
    
    func invalidateCache()
    {
        cache.removeAllObjects()
    }
    
    func addItem(item: AnyObject)
    {
        cache.setObject(item, forKey: indexForAdding)
        indexForRetrieving = indexForAdding - 1
        indexForAdding++
        
    }
    
    func lastAddedImage() -> UIImage?
    {
        indexForAdding = 0
        if let image = cache.objectForKey(indexForRetrieving) as? UIImage {
            indexForAdding = indexForRetrieving + 1
            indexForRetrieving--
            return image
        }
        return nil
    }
}
