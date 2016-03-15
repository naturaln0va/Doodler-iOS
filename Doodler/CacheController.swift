//
//  Created by Ryan Ackermann on 8/14/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class CacheController: NSObject
{
    static let sharedController = CacheController()
    var hasReachedMaxCount: Bool = false
    
    private(set) var cache = NSCache()
    private(set) var indexForAdding = 0
    private(set) var indexForRetrieving = 1
    
    private var count = 0
    private let maxCount = 20
    private var removedCount = 0
    
    func invalidateCache()
    {
        cache.removeAllObjects()
        count = 0
    }
    
    func addItem(item: AnyObject)
    {
        if count == maxCount {
            hasReachedMaxCount = true
            
            if removedCount >= maxCount {
                count = 0
                removedCount = 0
                indexForRetrieving = 1
                indexForAdding = 0
            }
            else {
                removedCount = 0
                
                if indexForAdding == maxCount {
                    indexForAdding = 0
                    indexForRetrieving = maxCount
                }
                else {
                    indexForRetrieving = indexForAdding - 1
                }
            }
        }
        else {
            indexForRetrieving = indexForAdding - 1
        }
        
        print("Adding index: \(indexForAdding)")
        cache.setObject(item, forKey: indexForAdding)
        indexForAdding++
        
        if count != maxCount {
            count = indexForAdding
        }
    }
    
    func lastAddedImage() -> UIImage?
    {
        if count != maxCount {
            indexForAdding = 0
            
            if indexForRetrieving == -1 {
                return nil
            }
        }
        print("Retrieveing index: \(indexForRetrieving)")
        if let image = cache.objectForKey(indexForRetrieving) as? UIImage {
            if count == maxCount {
                removedCount++
                if removedCount >= maxCount {
                    return cache.objectForKey(indexForRetrieving + 1) as? UIImage
                }
                if indexForRetrieving == 0 {
                    indexForAdding = indexForRetrieving + 1
                    indexForRetrieving = maxCount - 1
                }
                else if indexForRetrieving == maxCount - 1 {
                    indexForAdding = 0
                    indexForRetrieving--
                }
                else {
                    indexForAdding = indexForRetrieving + 1
                    indexForRetrieving--
                }
            }
            else {
                indexForAdding = indexForRetrieving + 1
                indexForRetrieving--
            }
            return image
        }
        return nil
    }
}
