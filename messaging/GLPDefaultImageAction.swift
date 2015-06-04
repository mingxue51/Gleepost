//
//  GLPDefaultImageAction.swift
//  CustomImagePickerSheetController
//
//  Created by Silouanos on 02/06/15.
//  Copyright (c) 2015 Silouanos. All rights reserved.
//

import UIKit

class GLPDefaultImageAction: GLPImageAction, Printable
{
    let title: String
    let secondaryTitle: String
    
    init(title: String, secondaryTitle: String)
    {
        self.title = title
        self.secondaryTitle = secondaryTitle
//        super.init()
    }
    
    override var description: String
    {
        return "title \(self.title) secondary title \(self.secondaryTitle)"
    }
    
    override func cellName() -> String {
        return "GLPDefaultImageActionCell"
    }
}
