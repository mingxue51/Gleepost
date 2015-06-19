//
//  UIView+GLPDesign.m
//  Gleepost
//
//  Created by Σιλουανός on 21/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "UIView+GLPDesign.h"
#import "ShapeFormatterHelper.h"
#import "AppearanceHelper.h"

@implementation UIView (GLPDesign)

- (void)setGleepostStyleBorder
{
    [ShapeFormatterHelper setCornerRadiusWithView:self andValue:5];
    
    [ShapeFormatterHelper setBorderToView:self withColour:[AppearanceHelper mediumGrayGleepostColour] andWidth:0.4f];
}

- (void)setGleepostStyleTopBorder
{
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, -1.0f, self.frame.size.width, 1.0f);
    topBorder.backgroundColor = [AppearanceHelper mediumGrayGleepostColour].CGColor;
    [self.layer addSublayer:topBorder];
}

@end