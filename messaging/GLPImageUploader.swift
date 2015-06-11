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
    
    /// Holds a timestamp as a key and the progress value as a value.
    
    private lazy var pendingOperationsStatus: [String : Float] = {
        let pendingOperationsStatus = [String : Float]()
        return pendingOperationsStatus
    }()
    
    override init() {
        super.init()
        self.configureObservers()
    }
    
    // MARK: - Configuration
    
    private func configureObservers()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNetworkStatus:", name: SwiftConstants.GLPNOTIFICATION_NETWORK_UPDATE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "progressUpdated:", name: SwiftConstants.GLPNOTIFICATION_UPLOADING_IMAGE_CHANGED_STATUS_INTERNAL, object: nil)
    }
    
    // MARK: - Notifications
    
    func updateNetworkStatus(notification: NSNotification)
    {
        let userInfo: Dictionary = notification.userInfo!
        
        let isNetwork = userInfo["status"] as! Bool

        if isNetwork
        {
            self.resumeOperationsAfterLoosingNetwork()
        }
    }
    
    /**
        Each NSOperation (GLPImageOperation) object sends notification to this
    */
    func progressUpdated(notification: NSNotification)
    {
        let data = notification.userInfo!
        let timestamp: String = data["timestamp"] as! String
        let progress: Float = data["status"] as! Float
        self.pendingOperationsStatus[timestamp] = progress
        self.postNotificationToVCAfterProgressChanged()
    }
    
    // MARK: - Operations
    
    func addItems(items: Array<UIImage>) -> Array<String>
    {
        var timestamps = Array<String>()
        
        for image in items
        {
            let timestamp = DateFormatterHelper.generateDateTimestamp()
            timestamps.append(timestamp)
            self.pendingOperations[timestamp] = image
            self.addOperation(timestamp, image: image)
        }
        
        return timestamps
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
    
    /**
        Selectes the smaller progress of all pending images and posting NSNotification
        to the view controller to change the progress.
    */
    private func postNotificationToVCAfterProgressChanged()
    {
        var smallestProgress: Float = 1.0
        var timestampOfSmallestProgress: String = ""
        
        for (timestamp, progress) in self.pendingOperationsStatus
        {
            if progress < smallestProgress
            {
                smallestProgress = progress
                timestampOfSmallestProgress = timestamp
            }
        }
        println("smallest var \(smallestProgress) all variables \(self.pendingOperationsStatus)")
        
        NSNotificationCenter.defaultCenter().postNotificationName(SwiftConstants.GLPNOTIFICATION_UPLOADING_IMAGE_CHANGED_STATUS, object: self, userInfo: ["status" : smallestProgress, "timestamp" : timestampOfSmallestProgress])

    }
    
    // MARK: - GLPImageOperationDelegate
    
    func imageUploaded(timestamp: String, image: UIImage, imageUrl: String)
    {
        self.pendingOperations.removeValueForKey(timestamp)
        
        println("GLPImageUploader imageUploaded pending operations left \(self.pendingOperations.count) image url \(imageUrl) timestamp \(timestamp)")
        
        //Inform UI that an image has uploaded.
        NSNotificationCenter.defaultCenter().postNotificationNameOnMainThread(SwiftConstants.GLPNOTIFICATION_CHAT_IMAGE_UPLOADED, object: self, userInfo: ["timestamp" : timestamp, "image_url" : imageUrl])
    }
}
