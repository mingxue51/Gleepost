//
//  GLPIntroAnimationHelper.h
//  Gleepost
//
//  Created by Silouanos on 25/03/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginView.h"

@interface GLPIntroAnimationHelper : NSObject

- (void)showLoginView:(LoginView *)loginView withWelcomeLabel:(UILabel *)label withSubTitleImageView:(UIImageView *)subTitleImageView;
- (void)hideLoginView:(LoginView *)loginView withWelcomeLabel:(UILabel *)label withSubTitleImageView:(UIImageView *)subTitleImageView;
- (void)moveTopImageToTop:(UIImageView *)topImageView withTopDistanceConstraint:(NSLayoutConstraint *)topDistance withTopLogoWidth:(NSLayoutConstraint *)topLogoWidth;
- (void)moveTopImageBackToTheMiddle:(UIImageView *)topImageView withTopDistanceConstraint:(NSLayoutConstraint *)topDistance withTopLogoWidth:(NSLayoutConstraint *)topLogoWidth;

@end
