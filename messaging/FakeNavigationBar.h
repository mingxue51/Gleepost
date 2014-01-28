//
//  FakeNavigationBar.h
//  Gleepost
//
//  Created by Silouanos on 27/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPTimelineViewController.h"

@interface FakeNavigationBar : UIView

extern CGFloat WIDTH_FAKE;
extern CGFloat HEIGHT_FAKE;

@property (weak, nonatomic) GLPTimelineViewController *delegate;

-(void)formatElements;

@end
