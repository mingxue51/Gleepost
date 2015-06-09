//
//  GLPPickImageHelper.swift
//  Gleepost
//
//  Created by Silouanos on 08/06/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Class that helps picking image using the iOS 8 modern image picker.
//  Developers should create an instance of this class to view controllers when
//  they want to use it.

import UIKit
import MobileCoreServices

@objc class GLPPickImageHelper: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    private var imagePickerSheetController: ImagePickerSheetController?
    
    private func initialiseAndConfigureImagePicker()
    {
        let imagePickerSheetController = ImagePickerSheetController()
        
        imagePickerSheetController.addInitialAction(GLPMultipleImagesAction(imagesNames: ["camera_roll", "capture", "search_image"], imageActionStyle: .MultipleOptions))
        
        imagePickerSheetController.addInitialAction(GLPImageDefaultImageAction(title: "Select a location", imageName: "pick_location", textColour:UIColor().customRGB(34.0, customG: 218.0, customB: 160.0) , imageActionStyle: .PickLocation))
        
        imagePickerSheetController.addInitialAction(GLPDefaultImageAction(title: "Cancel", textColour: UIColor().customRGB(167.0, customG: 167.0, customB: 167.0), imageActionStyle: .Cancel))
        
        imagePickerSheetController.addSecondaryAction(GLPDefaultImageAction(title: "Send 1 image", textColour: UIColor().customRGB(34.0, customG: 218.0, customB: 160.0), imageActionStyle: .SendImage))
        
        imagePickerSheetController.addSecondaryAction(GLPImageDefaultImageAction(title: "back to options", imageName: "back_to_pick_image", textColour: UIColor().customRGB(167.0, customG: 167.0, customB: 167.0), imageActionStyle: .BackToOptions))
        
        imagePickerSheetController.addSecondaryAction(GLPDefaultImageAction(title: "Cancel", textColour: UIColor().customRGB(167.0, customG: 167.0, customB: 167.0), imageActionStyle: .Cancel))
        
        self.imagePickerSheetController = imagePickerSheetController

    }
    
    private lazy var cameraView: UIImagePickerController = {
       
        let cameraView = UIImagePickerController()
        cameraView.sourceType = .Camera
        cameraView.mediaTypes = [kUTTypeImage]
        cameraView.allowsEditing = true
        cameraView.delegate = self

        return cameraView
    }()
    
    // MARK: - Public
    
    func presentImagePickerWithViewController(viewController: UIViewController)
    {
        self.initialiseAndConfigureImagePicker()
        imagePickerSheetController!.delegate = viewController as? ImagePickerSheetControllerDelegate
        viewController.presentViewController(imagePickerSheetController!, animated: true, completion: nil)
    }
    
    func presentCamera(viewController: UIViewController)
    {
        if !UIImagePickerController.isSourceTypeAvailable(.Camera)
        {
            return
        }
        
//        if !imagePickerSheetController!.isBeingDismissed()
//        {
//            imagePickerSheetController!.dismissViewControllerAnimated(true, completion: nil)
//        }
        
        viewController.presentViewController(cameraView, animated: true) { (completed) -> Void in
            
            println("GLPPickImageHelper presentCamera")
        }
    }
    
    // MARK - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!)
    {
        cameraView.dismissViewControllerAnimated(true, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(SwiftConstants.GLPNOTIFICATION_SELECTED_IMAGES, object: self, userInfo: ["images" : [image]])
        println("GLPPickImageHelper image \(image)")
    }
}
