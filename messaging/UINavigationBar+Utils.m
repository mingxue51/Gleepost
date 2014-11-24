//
//  UINavigationBar+Utils.m
//  Gleepost
//
//  Created by Σιλουανός on 12/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "UINavigationBar+Utils.h"
#import "ShapeFormatterHelper.h"
#import "AppearanceHelper.h"
#import "GLPThemeManager.h"

@implementation UINavigationBar (Utils)


#pragma mark - Default Navigation bar

/**
 This method is used only for special buttons that we want custom colour and not the default from theme manager.
 For now the special button variable will not have any effect.
 */

- (void)setButton:(GLPButtonType)type specialButton:(GLPSpecialButton)kind withImageName:(NSString *)imageOrTitle withButtonSize:(CGSize)size withSelector:(SEL)selector andTarget:(UIViewController *)navController

{
    UIButton *btn= [self generateButtonWithSize:size withSelector:selector andViewController:navController];
    
    UIBarButtonItem *barButtonItem = nil;
    
    [btn setBackgroundImage:[UIImage imageNamed:imageOrTitle] forState:UIControlStateNormal];
    
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

    if(type == kLeft)
    {
        [self addNewButton:barButtonItem withNavigationItem:navController.navigationItem inRightSide:NO];
    }
    else if (type == kRight)
    {
        [self addNewButton:barButtonItem withNavigationItem:navController.navigationItem inRightSide:YES];
    }
}

- (void)setButton:(GLPButtonType)type withImageName:(NSString *)imageOrTitle withButtonSize:(CGSize)size withSelector:(SEL)selector andTarget:(UIViewController *)navController
{
    UIButton *btn= [self generateButtonWithSize:size withSelector:selector andViewController:navController];
    
    UIBarButtonItem *barButtonItem = nil;

    if(type == kLeft)
    {
        UIImage *finalImage = [[GLPThemeManager sharedInstance] leftItemColouredImage:[UIImage imageNamed:imageOrTitle]];

        [btn setBackgroundImage:finalImage forState:UIControlStateNormal];
        
        barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        [self addNewButton:barButtonItem withNavigationItem:navController.navigationItem inRightSide:NO];
    }
    else if (type == kRight)
    {
        UIImage *finalImage = [[GLPThemeManager sharedInstance] rightItemColouredImage:[UIImage imageNamed:imageOrTitle]];
        
        [btn setBackgroundImage:finalImage forState:UIControlStateNormal];
        
        barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        [self addNewButton:barButtonItem withNavigationItem:navController.navigationItem inRightSide:YES];
    }
}

- (void)setTextButton:(GLPButtonType)type withTitle:(NSString *)title withButtonSize:(CGSize)size withSelector:(SEL)selector andTarget:(UIViewController *)navController
{
    UIBarButtonItem *fixedSpace = [self generateFixedSpaceBarButton];
    
    UIButton *btn= [self generateButtonWithSize:size withSelector:selector andViewController:navController];
    
    UIBarButtonItem *barButtonItem = nil;
    
    [btn setTitle:title forState:UIControlStateNormal];
    
    [btn setTitleColor:[AppearanceHelper greenGleepostColour] forState:UIControlStateNormal];
    
    [btn.titleLabel setFont:[UIFont fontWithName:GLP_CAMPUS_WALL_TITLE_FONT size:18.0]];
    
    [fixedSpace setWidth:-7];
    
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    navController.navigationItem.rightBarButtonItems = @[fixedSpace, barButtonItem];
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

/**
 Adds new bar button. If there are other bar buttons into the button items adds it on top of them.
 
 @param barButtonItem the new bar button.
 
 @param navigationItem the navigation item.
 
 @param rightSide if YES then the button is for the right side, if NO is for left side.
 
 */
- (void)addNewButton:(UIBarButtonItem *)barButtonItem withNavigationItem:(UINavigationItem *)navigationItem inRightSide:(BOOL)rightSide
{
    if(rightSide)
    {
        NSMutableArray *items = navigationItem.rightBarButtonItems.mutableCopy;
        
        if(!items)
        {
            UIBarButtonItem *fixedSpace = [self generateFixedSpaceBarButton];
            
            [fixedSpace setWidth:0];

            items = @[fixedSpace, barButtonItem].mutableCopy;
        }
        else
        {
            [items setObject:barButtonItem atIndexedSubscript:2];
        }
        
        navigationItem.rightBarButtonItems = items;

    }
    else
    {
        NSMutableArray *items = navigationItem.leftBarButtonItems.mutableCopy;
        
        if(!items)
        {
            UIBarButtonItem *fixedSpace = [self generateFixedSpaceBarButton];

            [fixedSpace setWidth:-2.6];
            
            items = @[fixedSpace, barButtonItem].mutableCopy;

        }
        else
        {
            [items setObject:barButtonItem atIndexedSubscript:2];
        }
        
        navigationItem.leftBarButtonItems = items;

    }
}

- (void)clearNavigationItemsWithNavigationController:(UIViewController *)navigationController
{
    navigationController.navigationItem.rightBarButtonItems = nil;

}

#pragma mark - Storyboard Navigation bar


/**
 This method is used for navigation bars that have been created from storyboard. NOT the default ones.
 
 @param type the type of the button.
 @param kind of button to help formatting it.
 @param image name of the image.
 @param size the size of the navigation button.
 @param selector the method to be called.
 @param viewController the view controller.
 @param navigationItem view controller's navigation item. (Note: Navigation item should be referenced from the storyboard to the navigation VC class, not the one from the default navigation bar.
 
 */
- (void)setButton:(GLPButtonType)type specialButton:(GLPSpecialButton)kind withImage:(NSString *)image withButtonSize:(CGSize)size withSelector:(SEL)selector withTarget:(UIViewController *)viewController andNavigationItem:(UINavigationItem *)navigationItem
{
    
//    UIBarButtonItem *fixedSpace = [self generateFixedSpaceBarButton];
    
    UIButton *btn= [self generateButtonWithSize:size withSelector:selector andViewController:viewController];
    
    UIBarButtonItem *barButtonItem = nil;
    
    
//    if(type == kLeft)
//    {
//        [fixedSpace setWidth:-4];
//        navigationItem.leftBarButtonItems = @[fixedSpace, barButtonItem];
//        
//    }
//    else if (type == kRight)
//    {
//        [fixedSpace setWidth:-5];
//        navigationItem.rightBarButtonItems = @[fixedSpace, barButtonItem];
//    }
    
    if(type == kLeft)
    {
        UIImage *finalImage = nil;
        
        if(kind == kNoSpecial || kind == kSettings)
        {
            finalImage = [[GLPThemeManager sharedInstance] leftItemColouredImage:[UIImage imageNamed:image]];

        }
        else if (kind == kQuit)
        {
            finalImage = [UIImage imageNamed:image];
        }
        
        [btn setBackgroundImage:finalImage forState:UIControlStateNormal];
        barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        [self addNewButton:barButtonItem withNavigationItem:navigationItem inRightSide:NO];
    }
    else if (type == kRight)
    {
        UIImage *finalImage = nil;
        
        if(kind == kNoSpecial || kind == kSettings)
        {
            finalImage = [[GLPThemeManager sharedInstance] rightItemColouredImage:[UIImage imageNamed:image]];
        }
        else if (kind == kQuit)
        {
            finalImage = [UIImage imageNamed:image];

        }
        
        [btn setBackgroundImage:finalImage forState:UIControlStateNormal];
        barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        [self addNewButton:barButtonItem withNavigationItem:navigationItem inRightSide:YES];
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
