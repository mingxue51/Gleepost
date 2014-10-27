//
//  GLPGroupSettingsViewController.h
//  Gleepost
//
//  Created by Silouanos on 30/09/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLPGroup;

@protocol GLPGroupSettingsViewControllerDelegate <NSObject>

@required
- (void)takeImage:(UIImage *)image;

@end

@interface GLPGroupSettingsViewController : UIViewController

@property (strong, nonatomic) GLPGroup *group;

@property (weak, nonatomic) UIViewController <GLPGroupSettingsViewControllerDelegate> *delegate;


@end
