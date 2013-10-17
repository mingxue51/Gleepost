//
//  GLPNavigationController.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPNavigationController.h"

@interface GLPNavigationController ()

@end

@implementation GLPNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    NSLog(@"VC %@", rootViewController);
    return [super initWithRootViewController:rootViewController];
}

- (id)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass
{
    NSLog(@"fu");
    return [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
}

- (id)init
{
    NSLog(@"blah");
    return [super init];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    NSLog(@"1");
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    NSLog(@"2");
}

@end
