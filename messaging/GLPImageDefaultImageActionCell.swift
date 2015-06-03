//
//  GLPImageDefaultImageActionCell.swift
//  CustomImagePickerSheetController
//
//  Created by Silouanos on 03/06/15.
//  Copyright (c) 2015 Silouanos. All rights reserved.
//

import UIKit

class GLPImageDefaultImageActionCell: GLPDefaultImageActionCell {

    @IBOutlet weak var leftImageView: UIImageView!
    
    
    override func setData(data: GLPDefaultImageAction, useSecondaryTitle: Bool) {
        super.setData(data, useSecondaryTitle: useSecondaryTitle)
        self.setImage(imageDefaultImageAction: data as! GLPImageDefaultImageAction)
    }
    
    private func setImage(#imageDefaultImageAction: GLPImageDefaultImageAction)
    {
        self.leftImageView.image = UIImage(named: imageDefaultImageAction.imageName)
    }

    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
