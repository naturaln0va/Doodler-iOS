//
//  RANewDocumentControllerDelegate.swift
//  Doodler
//
//  Created by Ryan Ackermann on 2/19/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

protocol RANewDocumentControllerDelegate {
    func newDocumentControllerDidCancel(controller: RANewDocumentViewController)
    
    // 'size' is the new document's size
    func newDocumentControllerDidFinish(controller: RANewDocumentViewController, size: CGSize)
}
