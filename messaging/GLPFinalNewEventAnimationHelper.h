//
//  GLPFinalNewEventAnimationHelper.h
//  Gleepost
//
//  Created by Silouanos on 09/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPAnimationHelper.h"

typedef NS_ENUM(NSInteger, FinalNewPostViewElement) {
    
    kImageElement,
    kVideoElement,
    kLocationElement,
    kTextElement,
    kTitleElement
};

@protocol GLPFinalNewEventAnimationHelperDelegate <GLPAnimationHelperDelegate>

@required
- (void)goingBackViewsDisappeared;

@end

@interface GLPFinalNewEventAnimationHelper : GLPAnimationHelper

- (void)setInitialValueInConstraint:(NSLayoutConstraint *)constraint forView:(UIView *)view comingFromRight:(BOOL)minusSign;
- (void)viewDidLoadAnimationWithConstraint:(NSLayoutConstraint *)constraint withKindOfElement:(FinalNewPostViewElement)kindOfElement;
- (void)viewGoingBack:(BOOL)goingBack disappearingAnimationWithView:(UIView *)view andKindOfElement:(FinalNewPostViewElement)kindOfElement;

@end
