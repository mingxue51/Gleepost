//
//  FakeNavigationBarView.h
//  Gleepost
//
//  Created by Σιλουανός on 4/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPFakeNavigationBarView.h"

@interface FakeNavigationBarView : GLPFakeNavigationBarView

- (id)initWithTitle:(NSString *)title;
- (void)setTitle:(NSString *)title;
- (void)setTitleToLabel:(NSString *)title;
- (void)setTitleColour:(UIColor *)colour;
- (void)setAlphaToTitle:(CGFloat)alpha;
- (void)configureTitle;
- (void)hideNavigationBar;
- (void)showNavigationBar;

@end
