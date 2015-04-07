//
//  GLPIntroNewPostAnimationHelper.h
//  Gleepost
//
//  Created by Silouanos on 06/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPAnimationHelper.h"

typedef NS_ENUM(NSUInteger, IntroNewPostViewElement) {
    kEventElement = 1,
    kQuestionElement,
    kAnnouncementElement,
    kGeneralElement,
    kPencilElement,
    kTitleElement,
    kNevermindElement = 99
};

@protocol GLPIntroNewPostAnimationHelperDelegate <GLPAnimationHelperDelegate>



@end

@interface GLPIntroNewPostAnimationHelper : GLPAnimationHelper

- (void)viewDidLoadAnimationWithConstraint:(NSLayoutConstraint *)layoutConstraint andKindOfElement:(IntroNewPostViewElement)kindOfElement;
- (void)viewDisappearingAnimationWithView:(UIView *)view andKindOfElement:(IntroNewPostViewElement)kindOfElement;
- (void)animateElementAfterComingBackWithConstraint:(NSLayoutConstraint *)layoutConstraint andKindOfElement:(IntroNewPostViewElement)kindOfElement;
- (void)renewFinalValueWithConstraint:(NSLayoutConstraint *)constraint forKindOfElement:(IntroNewPostViewElement)kindOfElement;
- (CGFloat)getInitialElementsPosition;

@end
