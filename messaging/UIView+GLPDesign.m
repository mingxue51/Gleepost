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

@end