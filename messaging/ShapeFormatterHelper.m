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

+(void)setTwoLeftCornerRadius:(UIImageView *)imageView withViewFrame:(CGRect)frame withValue:(int)value
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii:CGSizeMake(value, value)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = frame;
    maskLayer.path = maskPath.CGPath;
    imageView.layer.mask = maskLayer;
}

+(void)setTwoBottomCornerRadius:(UIView *)view withViewFrame:(CGRect)frame withValue:(int)value
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(value, value)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = frame;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

+(void)setTopCornerRadius:(UIView *)view withViewFrame:(CGRect)frame withValue:(int)value
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(value, value)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = frame;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

+(void)setCornerRadiusWithView:(UIView*)imageView andValue:(int)value
{
    imageView.layer.cornerRadius = value;
}

+(void)setElement:(UIView *)element withExtraHeight:(float)height
{    
    CGRect frame = element.frame;
    
    [element setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height)];
}

+(void)setElement:(UIView *)element withExtraY:(float)y
{
    CGRect frame = element.frame;
    
    [element setFrame:CGRectMake(frame.origin.x, y, frame.size.width, frame.size.height)];
}

/**
 Method used for test purposes.
 
 @param view
 @param colour
 */
+(void)setBorderToView:(UIView *)view withColour:(UIColor *)colour
{
    [view.layer setBorderColor:colour.CGColor];
    [view.layer setBorderWidth:2.0f];
    
}

@end
