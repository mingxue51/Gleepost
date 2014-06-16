//
//  UINavigationBar+Utils.m
//  Gleepost
//
//  Created by Σιλουανός on 12/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "UINavigationBar+Utils.h"
#import "ShapeFormatterHelper.h"

@implementation UINavigationBar (Utils)

- (void)setButton:(GLPButtonType)type withImageOrTitle:(NSString *)imageOrTitle withButtonSize:(CGSize)size withSelector:(SEL)selector andTarget:(UIViewController *)navController
{
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:navController action:selector forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:CGRectMake(0, 0, size.width, size.height)];
    btn.exclusiveTouch = YES;
    
    UIBarButtonItem *barButtonItem = nil;

    
    if(type == kText)
    {
        [btn setTitle:imageOrTitle forState:UIControlStateNormal];
        
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [fixedSpace setWidth:-7];
        
        barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        navController.navigationItem.rightBarButtonItems = @[fixedSpace, barButtonItem];
        
    }
    else
    {
        [btn setBackgroundImage:[UIImage imageNamed:imageOrTitle] forState:UIControlStateNormal];

        barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        if(type == kLeft)
        {
            [fixedSpace setWidth:-4];
            navController.navigationItem.leftBarButtonItems = @[fixedSpace, barButtonItem];
            
        }
        else if (type == kRight)
        {
            [fixedSpace setWidth:-5];
            navController.navigationItem.rightBarButtonItems = @[fixedSpace, barButtonItem];
        }
    }
}

- (void)setSystemButton:(GLPButtonType)type withBarButtonSystemItem:(UIBarButtonSystemItem)systemItem withSelector:(SEL)selector andTarget:(UIViewController *)navController
{
    UIBarButtonItem *groupButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:self action:selector];
    
    UIBarButtonItem *fixedSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if(type == kLeft)
    {
        [fixedSpaceButton setWidth:-4];

        navController.navigationItem.leftBarButtonItems = @[fixedSpaceButton, groupButton];
    }
    else if (type == kRight)
    {
        [fixedSpaceButton setWidth:-5]; //6

        navController.navigationItem.rightBarButtonItems = @[fixedSpaceButton, groupButton];
    }
    
}

@end
