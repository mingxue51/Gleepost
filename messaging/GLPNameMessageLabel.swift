//
//  GLPNameMessageLabel.swift
//  Gleepost
//
//  Created by Silouanos on 17/06/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Class that is used to represent the user's name above the bubble in GLPMessageCell.
//  This should be initialised only when the message belongs to a group messenger chat.

import UIKit

class GLPNameMessageLabel: GLPLabel
{
    private let customFont = UIFont.boldSystemFontOfSize(12.0)
    private let customTextColour = UIColor.lightGrayColor()
    private let customTextAlignment: NSTextAlignment = .Center
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureLabel()
    }
    
    init()
    {
        super.init(frame: CGRectMake(0.0, 0.0, GLPiOSSupportHelper.screenWidth(), GLPNameMessageLabel.labelHeight()))
        self.configureLabel()
    }

    //MARK: - Configuration
    
    private func configureLabel()
    {
        self.font = self.customFont
        self.textColor = self.customTextColour
        self.textAlignment = self.customTextAlignment
        self.backgroundColor = UIColor.clearColor()
    }
    
    func setUserName(#userName: String)
    {
        self.hidden = false
        self.text = userName
        self.frame = CGRectMake(50.0, 20.0, self.getContentLabelWidthForContent(userName), GLPNameMessageLabel.labelHeight())
    }

    //MARK: - Static
    
    class func labelHeight() -> CGFloat
    {
        return 10.0
    }
    
    class func labelBottomPadding() -> CGFloat
    {
        return 5.0
    }
    
    class func labelTopPadding() -> CGFloat
    {
        return 10.0
    }
    
    private func getContentLabelWidthForContent(content: String) -> CGFloat
    {
        var attributedText: NSAttributedString = NSAttributedString(string: content, attributes: [NSFontAttributeName : self.customFont])
        
        let rect: CGRect = attributedText.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: (.UsesLineFragmentOrigin | .UsesFontLeading), context: nil)
        
        return rect.size.width
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
