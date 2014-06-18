//
//  GLPButton.m
//  Gleepost
//
//  Created by Σιλουανός on 12/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class is used only when we place navigation items from storyboard.
//

#import "GLPButton.h"

@implementation GLPButton


- (UIEdgeInsets)alignmentRectInsets
{
    UIEdgeInsets insets;
    
    //If tag = 0 then it means that the current button is the left.
    //else the current button is the right.
    
    //The left's button X from the left edge (in storyboard) should be 16 from the right side.
    //The right's button X from the right edge (in storyboard) should be 304 from the left side.
    
    
    if(self.tag == 0)
    {
        insets = UIEdgeInsetsMake(0, 6.0f, 0, 0); //10
    }
    else
    {
        insets = UIEdgeInsetsMake(0, 0, 0, 12.0f); //18
    }
    
    return insets;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
