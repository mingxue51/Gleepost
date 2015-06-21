//
//  GLPImageDefaultImageAction.swift
//  CustomImagePickerSheetController
//
//  Created by Silouanos on 03/06/15.
//  Copyright (c) 2015 Silouanos. All rights reserved.
//
//  Model that holds a url as well. (Not only 2 titles).

import UIKit

class GLPImageDefaultImageAction: GLPDefaultImageAction
{
    let imageName: String
    
    init(title: String, imageName: String, textColour: UIColor, imageActionStyle: GLPImageActionStyle)
    {
        self.imageName = imageName
        super.init(title: title, textColour: textColour, imageActionStyle: imageActionStyle)
    }
    
    override func cellName() -> String {
        return "GLPImageDefaultImageActionCell"
    }
}
