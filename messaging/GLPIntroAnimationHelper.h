//
//  GLPIntroAnimationHelper.h
//  Gleepost
//
//  Created by Silouanos on 25/03/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RegisterView;

@interface GLPIntroAnimationHelper : NSObject

- (void)showRegisterView:(RegisterView *)loginView withWelcomeLabel:(UILabel *)label withSubTitleImageView:(UIImageView *)subTitleImageView;
- (void)hideRegisterView:(RegisterView *)loginView withWelcomeLabel:(UILabel *)label withSubTitleImageView:(UIImageView *)subTitleImageView;
- (void)moveTopImageToTop:(UIImageView *)topImageView withTopDistanceConstraint:(NSLayoutConstraint *)topDistance withTopLogoWidth:(NSLayoutConstraint *)topLogoWidth;
- (void)moveTopImageBackToTheMiddle:(UIImageView *)topImageView withTopDistanceConstraint:(NSLayoutConstraint *)topDistance withTopLogoWidth:(NSLayoutConstraint *)topLogoWidth;

@end
