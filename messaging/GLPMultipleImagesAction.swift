//
//  GLPMutipleImagesAction.swift
//  Gleepost
//
//  Created by Silouanos on 04/06/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

import UIKit

class GLPMultipleImagesAction: GLPImageAction
{
    let array: [String]
    
    init(imagesNames: [String], imageActionStyle: GLPImageActionStyle) {
        
        self.array = imagesNames
        super.init(imageActionStyle: imageActionStyle)
        
    }
    
    override func cellName() -> String {
        return "GLPMultipleImagesActionCell"
    }
}
