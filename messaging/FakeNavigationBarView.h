//
//  FakeNavigationBarView.h
//  Gleepost
//
//  Created by Σιλουανός on 4/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FakeNavigationBarView : UIView

- (id)initWithTitle:(NSString *)title;
- (void)setTitle:(NSString *)title;
- (void)hideNavigationBar;
- (void)showNavigationBar;

@end
