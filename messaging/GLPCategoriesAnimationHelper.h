//
//  GLPCategoriesAnimationHelper.h
//  Gleepost
//
//  Created by Silouanos on 02/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryManager.h"

@protocol GLPCategoriesAnimationHelperDelegate <NSObject>

@required
- (void)viewsDisappeared;

@end

@interface GLPCategoriesAnimationHelper : NSObject

@property (weak, nonatomic) UIViewController <GLPCategoriesAnimationHelperDelegate> *delegate;

- (void)animateElementWithTopConstraint:(NSLayoutConstraint *)topConstraint withKindOfView:(CategoryOrder)kindOfView;
- (void)dismissElementWithView:(UIView *)view withKindOfView:(CategoryOrder)kindOfView;
- (void)animateNevermindView:(UIView *)nevermindView withAppearance:(BOOL)show;
- (CGFloat)getInitialElementsPosition;

@end
