//
//  ShapeFormatterHelper.h
//  Gleepost
//
//  Created by Σιλουανός on 5/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShapeFormatterHelper : NSObject

+(void)setRoundedView:(UIImageView *)roundedView toDiameter:(float)newSize;

+(void)createTwoTopCornerRadius:(UIImageView*)imageView withViewBounts:(CGRect)viewBounds andSizeOfCorners:(CGSize)sizeOfCorners;

+(void)setCornerRadiusWithView:(UIView*)imageView andValue:(int)value;

@end
