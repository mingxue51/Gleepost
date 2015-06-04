//
//  GLPImageAction.swift
//  CustomImagePickerSheetController
//
//  Created by Silouanos on 02/06/15.
//  Copyright (c) 2015 Silouanos. All rights reserved.
//
//

import UIKit

public enum GLPImageActionStyle: Int
{
    case Default = 1
    case MultipleImages
    case Cancel
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
    override init()
    {
        
    }
    
    func cellName() -> String
    {
        return "GLPImageActionCell"
    }
}
