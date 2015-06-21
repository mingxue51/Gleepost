//
//  GLPCampusLiveViewController.h
//  Gleepost
//
//  Created by Silouanos on 04/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GLPCampusLiveViewControllerDelegate <NSObject>

@required
- (void)campusLiveDisappeared;

@end

@interface GLPCampusLiveViewController : UIViewController

@property (weak, nonatomic) UIViewController<GLPCampusLiveViewControllerDelegate> *delegate;

@end
