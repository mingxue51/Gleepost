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


#pragma mark - Default Navigation bar

- (void)setButton:(GLPButtonType)type withImageOrTitle:(NSString *)imageOrTitle withButtonSize:(CGSize)size withSelector:(SEL)selector andTarget:(UIViewController *)navController
{
    
    UIBarButtonItem *fixedSpace = [self generateFixedSpaceBarButton];
    
    UIButton *btn= [self generateButtonWithSize:size withSelector:selector andViewController:navController];
    
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
    UIBarButtonItem *groupButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:navController action:selector];
    
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

#pragma mark - Storyboard Navigation bar


/**
 This method is used for navigation bars that have been created from storyboard. NOT the default ones.
 
 @param type the type of the button.
 @param image name of the image.
 @param size the size of the navigation button.
 @param selector the method to be called.
 @param viewController the view controller.
 @param navigationItem view controller's navigation item. (Note: Navigation item should be referenced from the storyboard to the navigation VC class, not the one from the default navigation bar.
 
 */
- (void)setButton:(GLPButtonType)type withImage:(NSString *)image withButtonSize:(CGSize)size withSelector:(SEL)selector withTarget:(UIViewController *)viewController andNavigationItem:(UINavigationItem *)navigationItem
{
    
    UIBarButtonItem *fixedSpace = [self generateFixedSpaceBarButton];
    
    UIButton *btn= [self generateButtonWithSize:size withSelector:selector andViewController:viewController];
    
    UIBarButtonItem *barButtonItem = nil;
    
    [btn setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    if(type == kLeft)
    {
        [fixedSpace setWidth:-4];
        navigationItem.leftBarButtonItems = @[fixedSpace, barButtonItem];
        
    }
    else if (type == kRight)
    {
        [fixedSpace setWidth:-5];
        navigationItem.rightBarButtonItems = @[fixedSpace, barButtonItem];
    }
}

#pragma mark - Helpers

- (UIBarButtonItem *)generateFixedSpaceBarButton
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
}

- (UIButton *)generateButtonWithSize:(CGSize)size withSelector:(SEL)selector andViewController:(UIViewController *)viewController
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:viewController action:selector forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:CGRectMake(0, 0, size.width, size.height)];
    btn.exclusiveTouch = YES;
    
    return btn;
}

@end
