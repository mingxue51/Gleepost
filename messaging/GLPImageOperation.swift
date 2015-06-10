//
//  GLPImageOperation.swift
//  Gleepost
//
//  Created by Silouanos on 09/06/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

import Foundation
import UIKit

@objc protocol GLPImageOperationDelegate
{
    func imageUploaded(timestamp: String, image: UIImage, imageUrl: String)
}

class GLPImageOperation: NSOperation
{
    private var image: UIImage
    private let timestamp: String
    
    var delegate: GLPImageOperationDelegate?
    
    override func main()
    {
        self.processAndUploadImage()
    }
    
    init(timestamp: String, image: UIImage)
    {
        self.timestamp = timestamp
        self.image = image
        super.init()
        self.saveImageToCache()
    }
    
    
    //MARK: - Cache
    
    private func saveImageToCache()
    {
        GLPImageCacheHelper.storeImage(image, withImageUrl: timestamp)
    }
    
    private func replaceImageToCache(uploadedUrl: String)
    {
        GLPImageCacheHelper.replaceImage(image, withImageUrl: timestamp, andOldImageUrl: uploadedUrl)
    }
    
    //MARK: - Client
    
    private func processAndUploadImage()
    {
        
        WebClient.sharedInstance().uploadImage(resizeImageAndConvertToNSData(), callback: { (success, imageUrl) -> Void in
            
            if success
            {
                self .replaceImageToCache(imageUrl)
                self.delegate?.imageUploaded(self.timestamp, image: self.image, imageUrl: imageUrl)
            }
            else
            {
                println("GLPImageOperation error to upload image")
            }
            
        })
    }
    
    private func resizeImageAndConvertToNSData() -> NSData
    {
        self.image = ImageFormatterHelper.imageWithImage(self.image, scaledToHeight: 640.0)
        return UIImagePNGRepresentation(self.image)
    }
}
