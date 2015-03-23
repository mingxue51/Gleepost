//
//  UIImageVIew+GLPFormat.m
//  Gleepost
//
//  Created by Silouanos on 23/03/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "UIImageVIew+GLPFormat.h"
#import "GLPThemeManager.h"

@implementation UIImageView (GLPFormat)

- (void)applyCradientEffect
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.frame;
    
    // Add colors to layer
    UIColor *startColor = [[GLPThemeManager sharedInstance] tabbarSelectedColour];
    UIColor *endColor = [UIColor clearColor];
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[endColor CGColor],
                       (id)[startColor CGColor],
                       nil];
    
    [self.layer insertSublayer:gradient atIndex:0];
}

@end
