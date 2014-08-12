//
//  ShapeFormatterHelper.h
//  Gleepost
//
//  Created by Σιλουανός on 5/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShapeFormatterHelper : NSObject

+(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize;

+(void)createTwoTopCornerRadius:(UIImageView*)imageView withViewBounts:(CGRect)viewBounds andSizeOfCorners:(CGSize)sizeOfCorners;

+(void)setCornerRadiusWithView:(UIView*)imageView andValue:(int)value;

+(void)setTwoLeftCornerRadius:(UIImageView *)imageView withViewFrame:(CGRect)frame withValue:(int)value;

+(void)setTwoBottomCornerRadius:(UIView *)view withViewFrame:(CGRect)frame withValue:(int)value;

+(void)setElement:(UIView *)element withExtraHeight:(float)height;

+ (void)setBottomCornerRadius:(UIView *)view withValue:(float)value;

+(void)setTopCornerRadius:(UIView *)view withViewFrame:(CGRect)frame withValue:(int)value;

+ (void)removeBottomCornerRadius:(UIView *)view;

+(void)setElement:(UIView *)element withExtraY:(float)y;

+(void)setBorderToView:(UIView *)view withColour:(UIColor *)colour andWidth:(float)width;

+ (void)resetAnyFormatOnView:(UIView *)view;

+(void)setBorderToView:(UIView *)view withColour:(UIColor *)colour;

+ (void)setBorderToView:(UIView *)view inLine:(UIRectEdge)edge withColour:(UIColor *)colour andWidth:(float)width;

+ (void)setBottomExCornerRadius:(UIImageView *)imageView withValue:(float)value;

@end
