//
//  ShapeFormatterHelper.m
//  Gleepost
//
//  Created by Σιλουανός on 5/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ShapeFormatterHelper.h"

@implementation ShapeFormatterHelper


+(void)setRoundedView:(UIImageView *)roundedView toDiameter:(float)newSize
{
    roundedView.clipsToBounds = YES;
    
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}


/**
 Converts the two top corners of an image view from straight to circles.
 
 @param imageView the incoming image view.
 @param viewBounds the bounds of the parent view.
 @param sizeOfCorners the size of the new corners.
 
 */
+(void)createTwoTopCornerRadius:(UIImageView*)imageView withViewBounts:(CGRect)viewBounds andSizeOfCorners:(CGSize)sizeOfCorners
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:sizeOfCorners];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = viewBounds;
    maskLayer.path = maskPath.CGPath;
    imageView.layer.mask = maskLayer;
}

@end
