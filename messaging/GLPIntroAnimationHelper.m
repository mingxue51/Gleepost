//
//  GLPIntroAnimationHelper.m
//  Gleepost
//
//  Created by Silouanos on 25/03/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Helper used only in GLPLoginSignUpViewController and it is only for animation purposes.

#import "GLPIntroAnimationHelper.h"
#import "GLPiOSSupportHelper.h"

@interface GLPIntroAnimationHelper ()

@property (assign, nonatomic, readonly) CGFloat loginViewAnimationDuration;
@property (assign, nonatomic, readonly) CGFloat topDistanceAfterNewSession;
@property (assign, nonatomic, readonly) CGFloat topDistance;
@property (assign, nonatomic, readonly) CGFloat topLogoWidth;
@property (assign, nonatomic, readonly) CGFloat topLogoWidthAfterNewSession;

@end

@implementation GLPIntroAnimationHelper

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initialiseConstantsDuration];
        
    }
    return self;
}

#pragma mark - Configuration

- (void)initialiseConstantsDuration
{
    _loginViewAnimationDuration = 0.5;
    _topDistanceAfterNewSession = -20;
    _topDistance = 20;
    _topLogoWidth = [GLPiOSSupportHelper screenWidth] * 0.45;
    _topLogoWidthAfterNewSession = 100;
}

- (void)showLoginView:(LoginView *)loginView withWelcomeLabel:(UILabel *)label withSubTitleImageView:(UIImageView *)subTitleImageView
{
    [loginView setAlpha:0.0];
    [label setAlpha:0.0];
    [subTitleImageView setAlpha:0.0];
    [loginView setHidden:NO];
    [label setHidden:NO];
    
    [UIView animateWithDuration:self.loginViewAnimationDuration animations:^{
        
        [loginView setAlpha:1.0];
        [label setAlpha:1.0];
//        [subTitleImageView setAlpha:0.0];
        
    } completion:^(BOOL finished) {
        
        [subTitleImageView setHidden:YES];
        
    }];
}

- (void)hideLoginView:(LoginView *)loginView withWelcomeLabel:(UILabel *)label withSubTitleImageView:(UIImageView *)subTitleImageView
{

    [subTitleImageView setAlpha:0.0];
    [subTitleImageView setHidden:NO];
    
    [UIView animateWithDuration:self.loginViewAnimationDuration animations:^{
        
        [loginView setAlpha:0.0];
        [label setAlpha:0.0];
        [subTitleImageView setAlpha:1.0];
        
    } completion:^(BOOL finished) {
        
        [subTitleImageView setHidden:NO];
        [loginView setHidden:YES];
        [label setHidden:YES];
        
    }];
}

- (void)moveTopImageToTop:(UIImageView *)topImageView withTopDistanceConstraint:(NSLayoutConstraint *)topDistance withTopLogoWidth:(NSLayoutConstraint *)topLogoWidth
{
    [topImageView layoutIfNeeded];
    
    [UIView animateWithDuration:self.loginViewAnimationDuration animations:^{

        [topDistance setConstant:_topDistanceAfterNewSession];
        [topLogoWidth setConstant:_topLogoWidthAfterNewSession];
        [topImageView layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)moveTopImageBackToTheMiddle:(UIImageView *)topImageView withTopDistanceConstraint:(NSLayoutConstraint *)topDistance withTopLogoWidth:(NSLayoutConstraint *)topLogoWidth
{
    [topImageView layoutIfNeeded];
    
    [UIView animateWithDuration:self.loginViewAnimationDuration animations:^{
        
        [topDistance setConstant:_topDistance];
        [topLogoWidth setConstant:_topLogoWidth];
        [topImageView layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
}

@end