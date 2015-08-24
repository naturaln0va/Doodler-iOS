//
//  Created by Joshua Smith on 7/5/14.
//  Copyright (c) 2014 iJoshSmith. All rights reserved.
//

import Foundation

infix operator ~> {}

/** Serial dispatch queue used by the ~> operator. */
private let queue = isIOS8OrLater() ? dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0) : dispatch_queue_create("background-queue-worker", DISPATCH_QUEUE_PRIORITY_BACKGROUND)

/**
Executes the lefthand closure on a background thread and,
upon completion, the righthand closure on the main thread.
*/
func ~> (
    backgroundClosure: () -> (),
    mainClosure:       () -> ())
{
    dispatch_async(queue) {
        backgroundClosure()
        dispatch_async(dispatch_get_main_queue(), mainClosure)
    }
}

/**
Executes the lefthand closure on a background thread and,
upon completion, the righthand closure on the main thread.
Passes the background closure's output to the main closure.
*/
func ~> <R> (
    backgroundClosure: () -> R,
    mainClosure:       (result: R) -> ())
{
    dispatch_async(queue) {
        let result = backgroundClosure()
        dispatch_async(dispatch_get_main_queue(), {
            mainClosure(result: result)
        })
    }
}

/**
Executes a closure on a background thread
*/
func async(closure: () -> ())
{
    dispatch_async(queue) {
        closure
    }
}

