//
//  GLPCategoriesAnimationHelper.h
//  Gleepost
//
//  Created by Silouanos on 02/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryManager.h"
#import "GLPAnimationHelper.h"

@protocol GLPCategoriesAnimationHelperDelegate <GLPAnimationHelperDelegate>

@end

@interface GLPCategoriesAnimationHelper : GLPAnimationHelper

- (void)animateElementWithTopConstraint:(NSLayoutConstraint *)topConstraint withKindOfView:(CategoryOrder)kindOfView;
- (void)dismissElementWithView:(UIView *)view withKindOfView:(CategoryOrder)kindOfView;
- (void)animateNevermindView:(UIView *)nevermindView withAppearance:(BOOL)show;

@end
