//
//  GLPIntroNewPostAnimationHelper.h
//  Gleepost
//
//  Created by Silouanos on 06/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPAnimationHelper.h"
#import "PendingPostManager.h"

@protocol GLPIntroNewPostAnimationHelperDelegate <GLPAnimationHelperDelegate>



@end

@interface GLPIntroNewPostAnimationHelper : GLPAnimationHelper


- (void)firstViewAnimationsWithView:(UIView *)view;
- (void)viewDidLoadAnimationWithConstraint:(NSLayoutConstraint *)layoutConstraint;
- (CGFloat)getInitialElementsPosition;

@end
