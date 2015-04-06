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
    kEventElement,
    kQuestionElement,
    kAnnouncementElement,
    kGeneralElement,
    kPencilElement,
    kTitleElement
};

@protocol GLPIntroNewPostAnimationHelperDelegate <GLPAnimationHelperDelegate>



@end

@interface GLPIntroNewPostAnimationHelper : GLPAnimationHelper


- (void)firstViewAnimationsWithView:(UIView *)view;
- (void)viewDidLoadAnimationWithConstraint:(NSLayoutConstraint *)layoutConstraint andKindOfElement:(IntroNewPostViewElement)kindOfElement;
- (CGFloat)getInitialElementsPosition;

@end
