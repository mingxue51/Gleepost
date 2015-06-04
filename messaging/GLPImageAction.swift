//
//  GLPImageAction.swift
//  CustomImagePickerSheetController
//
//  Created by Silouanos on 02/06/15.
//  Copyright (c) 2015 Silouanos. All rights reserved.
//
//

import UIKit

@objc enum GLPImageActionStyle: Int
{
    case PickLocation
    case MultipleOptions
    case Cancel
    case SendImage
    case BackToOptions
}

/**
    Each class that inherits the GLPImageAction should
    implement the cellName to be used in the ImagePickerSheetController.
*/
protocol GLPImageActionProtocol
{
    mutating func cellName() -> String
}

@objc class GLPImageAction: NSObject, GLPImageActionProtocol
{
    let imageActionStyle: GLPImageActionStyle
    
    init(imageActionStyle: GLPImageActionStyle)
    {
        self.imageActionStyle = imageActionStyle
    }
    
    func cellName() -> String
    {
        return "GLPImageActionCell"
    }
}
