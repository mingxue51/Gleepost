//
//  GLPImageUploader.swift
//  Gleepost
//
//  Created by Silouanos on 09/06/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

import Foundation
import UIKit

@objc class GLPImageUploader: NSObject, GLPImageOperationDelegate
{
    static let sharedInstance = GLPImageUploader()
    
    //Properties.
    private lazy var operationQueue: NSOperationQueue = {
        let operationQueue = NSOperationQueue()
        
        if !GLPiOSSupportHelper.isIOS7()
        {
            operationQueue.qualityOfService = .Utility
        }
        
        return operationQueue
    }()
    
    
    /// Holds a timestamp as a key and the pending image as a value.
    
    private lazy var pendingOperations: [String : UIImage] = {
        let pendingOperations = [String : UIImage]()
        return pendingOperations
    }()
    
    // MARK: - Configuration
    
    private func configureObservers()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNetworkStatus:", name: SwiftConstants.GLPNOTIFICATION_NETWORK_UPDATE, object: nil)
    }
    
    // MARK: - Notifications
    
    func updateNetworkStatus(notification: NSNotification)
    {
        println("GLPImageUploader updateNetworkStatus \(notification)")
        
        
        let userInfo: Dictionary = notification.userInfo!
        
        let isNetwork = userInfo["status"] as! Bool

        if isNetwork
        {
            self.resumeOperationsAfterLoosingNetwork()
        }
    }
    
    func addItems(items: Array<UIImage>)
    {
        for image in items
        {
            let timestamp = DateFormatterHelper.generateDateTimestamp()
            self.pendingOperations[timestamp] = image
            self.addOperation(timestamp, image: image)
        }
    }
    
    /**
        This method should be called only when network comes from 
        offline status.
    */
    private func resumeOperationsAfterLoosingNetwork()
    {
        for (timestamp, image) in self.pendingOperations
        {
            self.addOperation(timestamp, image: image)
        }
    }
    
    private func addOperation(timestamp: String, image: UIImage)
    {
        let operation = GLPImageOperation(timestamp: timestamp, image: image)
        operation.delegate = self
        self.operationQueue.addOperation(operation)
    }
    
    // MARK: - GLPImageOperationDelegate
    
    func imageUploaded(timestamp: String, image: UIImage, imageUrl: String)
    {
        self.pendingOperations.removeValueForKey(timestamp)
        
        println("GLPImageUploader imageUploaded pending operations left \(self.pendingOperations.count) image url \(imageUrl)")
        
        //TODO: Inform UI for changes.
        //                    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPImageUploaded" object:nil userInfo:@{@"imageUrl":imageUrlSend}];

    }
}
