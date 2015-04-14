//
//  UIView+RoudedCorners.m
//  Gleepost
//
//  Created by Σιλουανός on 12/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "UIView+RoudedCorners.h"
#import <QuartzCore/QuartzCore.h>
#import "AppearanceHelper.h"

@implementation UIView (RoudedCorners)

- (void)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius
{    
//    CGRect rect = self.bounds;
    
//    // Create the path
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
//    
//    // Create the shape layer and set its path
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame = rect;
//    maskLayer.path = maskPath.CGPath;
//
//    self.layer.mask = maskLayer;
    [self layoutIfNeeded];
    
    CGRect bounds = self.bounds;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    bounds.size.height -= 20;
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    
        
    self.layer.mask = maskLayer;
    
    CAShapeLayer *frameLayer = [CAShapeLayer layer];
    frameLayer.frame = bounds;
    frameLayer.path = maskPath.CGPath;
    frameLayer.strokeColor = [AppearanceHelper mediumGrayGleepostColour].CGColor;
    frameLayer.lineWidth = 2.0;
    frameLayer.fillColor = nil;

    [self.layer addSublayer:frameLayer];
//
//    [self setNeedsDisplay];
    
}

@end
