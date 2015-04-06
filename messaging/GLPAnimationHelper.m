//
//  GLPAnimationHelper.m
//  Gleepost
//
//  Created by Silouanos on 06/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Super-class of animation helpers.

#import "GLPAnimationHelper.h"
#import "GLPiOSSupportHelper.h"

@implementation GLPAnimationHelper

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self configureData];
    }
    
    return self;
}

/**
 Abstract method.
 */
- (void)configureData
{
    
}

#pragma mark - Helpers

- (CGFloat)getInitialElementsPosition
{
    return [GLPiOSSupportHelper screenHeight];
}

@end
