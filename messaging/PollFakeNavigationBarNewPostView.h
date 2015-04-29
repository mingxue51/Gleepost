//
//  PollFakeNavigationBarNewPostView.h
//  Gleepost
//
//  Created by Silouanos on 29/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "FakeNavigationBarNewPostView.h"

typedef NS_ENUM(NSUInteger, PollViewElement) {
    kQuestionTextView,
    kAnswerTextField
};


@interface PollFakeNavigationBarNewPostView : FakeNavigationBarNewPostView

- (void)setNumberOfCharacters:(NSInteger)charsNumber toElement:(PollViewElement)element;
- (void)elementChangedFocus:(PollViewElement)element;

@end
