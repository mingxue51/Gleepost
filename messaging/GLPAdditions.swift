//
//  GLPAdditions.swift
//  GleepostApprove
//
//  Created by Silouanos on 02/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

import UIKit

extension UIColor
{
    func customRGB(customR: Float, customG: Float, customB: Float) -> UIColor
    {
        let colour = UIColor(red: CGFloat(customR/255.0), green: CGFloat(customG/255.0), blue: CGFloat(customB/255.0), alpha: CGFloat(1.0))
        
        return colour
    }
    
    func customRGB(customR: CGFloat, customG: CGFloat, customB: CGFloat, alpha: CGFloat) -> UIColor
    {
        return UIColor(red: customR/255.0, green: customG/255.0, blue: customB/255.0, alpha: alpha)
    }
}
