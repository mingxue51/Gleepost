//
//  UIView+RoudedCorners.h
//  Gleepost
//
//  Created by Σιλουανός on 12/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RoudedCorners)

- (void)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius;
- (void)setBorderToViewInLine:(UIRectEdge)edge withColour:(UIColor *)colour andWidth:(float)width;

@end
