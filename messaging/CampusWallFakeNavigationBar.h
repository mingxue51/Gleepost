//
//  CampusWallFakeNavigationBar.h
//  Gleepost
//
//  Created by Silouanos on 14/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  This class inherits from FakeNavigationBarView because it has title label
//  and it uses some animations we want to be applied here as well.

#import "FakeNavigationBarView.h"

@protocol CampusWallFakeNavigationBarDelegate <NSObject>

- (void)leftButtonTouched;
- (void)rightButtonTouched;

@end

@interface CampusWallFakeNavigationBar : FakeNavigationBarView

@property (assign, nonatomic) UIViewController <CampusWallFakeNavigationBarDelegate> *delegate;

- (BOOL)isTransparentMode;
- (void)transparentMode;
- (void)colourMode;

@end
