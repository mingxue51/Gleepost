//
//  GLPBottomTextView.h
//  Gleepost
//
//  Created by Silouanos on 13/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLPBottomTextView : UIView

- (void)becomeTextViewFirstResponder;
- (void)resignTextViewFirstResponder;
- (BOOL)isTextViewFirstResponder;
- (void)hide;
- (void)show;

@end
