//
//  GLPEventNewPostAnimationHelper.h
//  Gleepost
//
//  Created by Silouanos on 07/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPAnimationHelper.h"

typedef NS_ENUM(NSInteger, EventNewPostViewElement) {
    
    kPartiesElement,
    kFreeFoodElement,
    kSportsElement,
    kSpeakersElement,
    kMusicElement,
    kTheaterElement,
    kOtherElement,
    kCalendarElement
};

@protocol GLPEventNewPostAnimationHelperDelegate <GLPAnimationHelperDelegate>

@required
- (void)goingBackViewsDisappeared;
- (void)goingForwardViewsDisappeared;

@end

@interface GLPEventNewPostAnimationHelper : GLPAnimationHelper

- (void)setInitialValueInConstraint:(NSLayoutConstraint *)constraint forView:(UIView *)view withMinusSign:(BOOL)minusSign;
- (void)setXValueForView:(UIView *)view withKindOfElement:(EventNewPostViewElement)kindOfElement;
- (void)renewDelay:(CGFloat)delay withKindOfElement:(EventNewPostViewElement)kindOfElement;
- (void)viewDidLoadAnimationWithConstraint:(NSLayoutConstraint *)constraint withKindOfElement:(EventNewPostViewElement)kindOfElement;
- (void)viewGoingBack:(BOOL)goingBack disappearingAnimationWithView:(UIView *)view andKindOfElement:(EventNewPostViewElement)kindOfElement;

@end
