//
//  GLPFakeNavigationBar.h
//  Gleepost
//
//  Created by Silouanos on 06/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLPFakeNavigationBarView : UIView

@property (strong, nonatomic) GLPFakeNavigationBarView *externalView;

- (instancetype)initWithNibName:(NSString *)nibName;
- (void)formatNavigationBar;

@end
