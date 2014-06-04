//
//  UIColor+GLPAdditions.m
//  Gleepost
//
//  Created by Silouanos on 02/06/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "UIColor+GLPAdditions.h"

@implementation UIColor (GLPAdditions)

+ (UIColor *)colorWithR:(float)r withG:(float)g andB:(float)b
{
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0];
}

@end
