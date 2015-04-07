//
//  GLPEventNewPostAnimationHelper.h
//  Gleepost
//
//  Created by Silouanos on 07/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPAnimationHelper.h"

//IntroNewPostViewElement

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

@interface GLPEventNewPostAnimationHelper : GLPAnimationHelper

- (void)setInitialValueInConstraint:(NSLayoutConstraint *)constraint forView:(UIView *)view;
- (void)setXValueForView:(UIView *)view withKindOfElement:(EventNewPostViewElement)kindOfElement;
- (void)viewDidLoadAnimationWithConstraint:(NSLayoutConstraint *)constraint withKindOfElement:(EventNewPostViewElement)kindOfElement;

@end
