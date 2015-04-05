//
//  UINavigationBar+Utils.h
//  Gleepost
//
//  Created by Σιλουανός on 12/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GLPButtonType) {
    kRight,
    kLeft
};

typedef NS_ENUM(NSUInteger, GLPSpecialButton) {
    kNoSpecial,
    kSettings,
    kQuit
};

@interface UINavigationBar (Utils)

//- (void)setButtonOnLeft:(BOOL)left withImageName:(NSString *)image withSelector:(SEL)selector andTarget:(UIViewController *)navController;
//
//- (void)setButtonOnRightWithImageName:(NSString *)image withButtonSize:(CGSize)size withSelector:(SEL)selector andTarget:(UIViewController *)navController;
//
//- (void)setButtonOnLeftWithImageName:(NSString *)image withButtonSize:(CGSize)size withSelector:(SEL)selector andTarget:(UIViewController *)navController;

- (void)setSystemButton:(GLPButtonType)type withBarButtonSystemItem:(UIBarButtonSystemItem)systemItem withSelector:(SEL)selector andTarget:(UIViewController *)navController;

- (void)setButton:(GLPButtonType)type specialButton:(GLPSpecialButton)kind withImageName:(NSString *)imageOrTitle withButtonSize:(CGSize)size withSelector:(SEL)selector andTarget:(UIViewController *)navController;


- (void)setButton:(GLPButtonType)type withImageName:(NSString *)imageOrTitle withButtonSize:(CGSize)size withSelector:(SEL)selector andTarget:(UIViewController *)navController;

//- (void)setTextButton:(GLPButtonType)type withTitle:(NSString *)title withButtonSize:(CGSize)size withSelector:(SEL)selector andTarget:(UIViewController *)navController;
- (void)setTextButton:(GLPButtonType)type withTitle:(NSString *)title withButtonSize:(CGSize)size withColour:(UIColor *)colour withSelector:(SEL)selector andTarget:(UIViewController *)navController;
- (void)clearNavigationItemsWithNavigationController:(UIViewController *)navigationController;

- (void)setButton:(GLPButtonType)type specialButton:(GLPSpecialButton)kind withImage:(NSString *)image withButtonSize:(CGSize)size withSelector:(SEL)selector withTarget:(UIViewController *)viewController andNavigationItem:(UINavigationItem *)navigationItem;

@end
