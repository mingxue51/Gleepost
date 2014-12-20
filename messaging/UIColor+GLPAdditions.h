//
//  UIColor+GLPAdditions.h
//  Gleepost
//
//  Created by Silouanos on 02/06/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (GLPAdditions)

+ (UIColor *)colorWithR:(float)r withG:(float)g andB:(float)b;
- (UIImage *)filledImageFrom:(UIImage *)source;

@end
