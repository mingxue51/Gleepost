//
//  GLPBackgroundMessageImageView.swift
//  Gleepost
//
//  Created by Silouanos on 17/06/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Class that is used to represent the background bubble in GLPMessageCell.

import UIKit

@objc enum BubbleType: Int
{
    case Incoming
    case Outgoing
    case IncomingTailless
    case OutgoingTailless
}

class GLPBackgroundMessageImageView: UIImageView
{
    private let capInsets = UIEdgeInsetsMake(17.5, 24.0, 17.5, 24.0)
    
    private lazy var incomingBubbleColour: UIColor = {
        return AppearanceHelper.lightGrayGleepostColour()
    }()
    
    private lazy var outgoingBubbleColour: UIColor = {
        return AppearanceHelper.greenGleepostColour()
    }()
    
    private lazy var outgoingBubbleImage: UIImage = {
        var incomingBubbleImage = self.setColourToImage(UIImage(named: "bubble_stroked")!, colour: self.outgoingBubbleColour)
        incomingBubbleImage = incomingBubbleImage.resizableImageWithCapInsets(self.capInsets, resizingMode: .Stretch)
        return incomingBubbleImage
    }()
    
    private lazy var incomingBubbleImage: UIImage = {
        var outgoingBubbleImage = self.setColourToImage(UIImage(named: "bubble_stroked")!, colour: self.incomingBubbleColour)
        outgoingBubbleImage = UIImage(CGImage: outgoingBubbleImage.CGImage, scale: outgoingBubbleImage.scale, orientation: .UpMirrored)!
        outgoingBubbleImage = outgoingBubbleImage.resizableImageWithCapInsets(self.capInsets, resizingMode: .Stretch)
        return outgoingBubbleImage
    }()
    
    private lazy var outgoingTaillessBubbleImage: UIImage = {
        var taillessBubbleImage = self.setColourToImage(UIImage(named: "bubble_stroked_tailless")!, colour: self.outgoingBubbleColour)
        taillessBubbleImage = taillessBubbleImage.resizableImageWithCapInsets(self.capInsets, resizingMode: .Stretch)
        return taillessBubbleImage
    }()
    
    private lazy var incomingTaillesBubbleImage: UIImage = {
       
        var incomingTaillesBubbleImage = self.setColourToImage(UIImage(named: "bubble_stroked_tailless")!, colour: self.incomingBubbleColour)
        incomingTaillesBubbleImage = incomingTaillesBubbleImage.resizableImageWithCapInsets(self.capInsets, resizingMode: .Stretch)
        return incomingTaillesBubbleImage
        
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureImageView()
    }
    
    //MARK: - Configuration
    
    private func configureImageView()
    {
        self.userInteractionEnabled = false
        self.contentMode = .ScaleToFill
        self.backgroundColor = UIColor.clearColor()
        self.hidden = true
        self.image = self.incomingBubbleImage
    }
    
    //MARK: - Public
    
    func changeImageView(bubbleType: BubbleType, size: CGRect)
    {
        switch bubbleType
        {
        case .Incoming:
            self.image = self.incomingBubbleImage
            
        case .Outgoing:
            self.image = self.outgoingBubbleImage
            
        case .IncomingTailless:
            self.image = self.incomingTaillesBubbleImage
            
        case .OutgoingTailless:
            self.image = self.outgoingTaillessBubbleImage

        }
        
        self.hidden = false
        self.frame = CGRectMake(0.0, 0.0, size.width + 5, size.height)
    }

    //MARK: - Helpers
    
    private func setColourToImage(image: UIImage, colour: UIColor) -> UIImage
    {
        let imageRect = CGRectMake(0.0, 0.0, image.size.width, image.size.height)
    
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextTranslateCTM(context, 0.0, -(imageRect.size.height));
        CGContextClipToMask(context, imageRect, image.CGImage);
        CGContextSetFillColorWithColor(context, colour.CGColor);
        CGContextFillRect(context, imageRect);
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return newImage
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
