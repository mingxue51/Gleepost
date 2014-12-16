//
//  UIImageView+CommonHelper.m
//  Gleepost
//
//  Created by Lukas on 2/28/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "UIImageView+CommonHelper.h"

@implementation UIImageView (CommonHelper)

+ (UIImageView *)newWithImageName:(NSString *)name
{
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
}

@end