//
//  GLPProfileMessageImageView.swift
//  Gleepost
//
//  Created by Silouanos on 16/06/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

import UIKit

class GLPProfileMessageImageView: UIImageView
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureImageView()
    }

    //MARK: - Configuration
    
    private func configureImageView()
    {
        self.userInteractionEnabled = true
        self.contentMode = .ScaleAspectFill
        ShapeFormatterHelper.setRoundedView(self, toDiameter: self.frame.size.height)
    }
    
    //MARK: - Modifiers
    
    func setGesture(target: UITableViewCell, selector: Selector)
    {
        let tapGestureRecognizer = UITapGestureRecognizer(target: target, action: selector)
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    /**
        Sets the image using the passed url. If the imageUrl is nil then assign 
        the default image or the initials image (that is going to be added in the
        future).
        
        :param: imageUrl the user's image url.
        :param: hasProfileImage if user has not a profile image url should pass false.
        :param: userName this is used in case user has not profile image. Instead of
        profile image we generate a name initials name.
    */
    func setImage(imageUrl: String, hasProfileImage: Bool, userName: String)
    {
        if hasProfileImage
        {
            self.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: GLPImageHelper.placeholderUserImage(), options: SDWebImageOptions.RetryFailed)
        }
        else
        {
            self.setImageWithString(userName)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
