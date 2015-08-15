//
//  Created by Ryan Ackermann on 8/14/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class CacheController: NSObject
{
    static let sharedController = CacheController()
    
    private(set) var cache: NSCache
    private(set) var count: Int
    
    override init()
    {
        cache = NSCache()
        count = 0
        
        super.init()
    }
    
    func invalidateCache()
    {
        cache.removeAllObjects()
    }
    
    func addItem(item: AnyObject)
    {
        cache.setObject(item, forKey: "\(count)")
    }
    
    func itemForIndex(index: Int) -> AnyObject?
    {
        let item: AnyObject? = cache.objectForKey("\(index)")
        cache.removeObjectForKey("\(index)")
        return item
    }
}
