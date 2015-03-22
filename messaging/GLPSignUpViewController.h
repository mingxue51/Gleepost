//
//  GLPSignUpViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 7/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPRegisterViewController.h"
#import "GLPLoginSignUpViewController.h"
#import "ImageSelectorViewController.h"

@interface GLPSignUpViewController : GLPRegisterViewController <UINavigationControllerDelegate, ImageSelectorViewControllerDelegate>

@property (strong, nonatomic) NSDictionary *facebookLoginInfo;
@property (weak, nonatomic) GLPLoginSignUpViewController *parentVC;

@end