//
//  GLPVisibleViewControllersManager.m
//  Gleepost
//
//  Created by Silouanos on 09/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  This class should preserves the visibility state of view controllers for any purpose.
//  For now this class trackes the visibility of GLPTimelineViewController.

#import "GLPVisibleViewControllersManager.h"

@interface GLPVisibleViewControllersManager ()

@property (assign, nonatomic, getter=isCampusWallVisible) BOOL campusWallVisible;

@end

@implementation GLPVisibleViewControllersManager

static GLPVisibleViewControllersManager *instance = nil;

+ (GLPVisibleViewControllersManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPVisibleViewControllersManager alloc] init];
    });
    
    return instance;
}

- (void)campusWallVisible:(BOOL)visible
{
    _campusWallVisible = visible;
}



@end
