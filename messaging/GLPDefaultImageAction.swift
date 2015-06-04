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
    var title: String
    let textColour: UIColor
    var imagesCount: Int
    
    init(title: String, textColour: UIColor, imageActionStyle: GLPImageActionStyle)
    {
        self.title = title
        self.textColour = textColour
        self.imagesCount = 1
        super.init(imageActionStyle: imageActionStyle)
    }
    
    func increaseCount(newNumber: Int)
    {
        var finalIndex = 0
        title = title.stringByReplacingOccurrencesOfString("\(self.imagesCount)", withString: "\(newNumber)", options: NSStringCompareOptions.LiteralSearch, range: nil)
        self.imagesCount = newNumber
    }
    
    override var description: String
    {
        return "title \(self.title)"
    }
    
    override func cellName() -> String {
        return "GLPDefaultImageActionCell"
    }
}
