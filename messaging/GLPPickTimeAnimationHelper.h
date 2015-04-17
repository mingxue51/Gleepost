//
//  GLPPickTimeAnimationHelper.h
//  Gleepost
//
//  Created by Silouanos on 08/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPAnimationHelper.h"

typedef NS_ENUM(NSInteger, PickTimeNewPostViewElement) {
    
    kTitleElement,
    kTimeElement,
    kButtonElement
};

@protocol GLPPickTimeAnimationHelperDelegate <GLPAnimationHelperDelegate>

@required
- (void)goingBackViewsDisappeared;
- (void)goingForwardViewsDisappeared;

@end

@interface GLPPickTimeAnimationHelper : GLPAnimationHelper

- (void)setInitialValueInConstraint:(NSLayoutConstraint *)constraint forView:(UIView *)view comingFromRight:(BOOL)minusSign;
- (void)viewDidLoadAnimationWithConstraint:(NSLayoutConstraint *)constraint withKindOfElement:(PickTimeNewPostViewElement)kindOfElement;
- (void)viewGoingBack:(BOOL)goingBack disappearingAnimationWithView:(UIView *)view andKindOfElement:(PickTimeNewPostViewElement)kindOfElement;

@end
