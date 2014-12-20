//
//  UIImageView+Animations.m
//  Gleepost
//
//  Created by Silouanos on 16/12/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "UIImageView+Animations.h"

@implementation UIImageView (Animations)

- (void)setImageWithAnimation:(UIImage *)image
{
    self.alpha = 0.0;
    [self setImage:image];
    
    [UIView animateWithDuration:0.5 animations:^{
       
        self.alpha = 1.0;
    }];
}

@end
