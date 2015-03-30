//
//  GLPVerificationViewController.h
//  Gleepost
//
//  Created by Silouanos on 27/03/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GLPVerificationViewControllerDelegate <NSObject>

@required
- (void)changeEmailAfterFacebookLogin:(NSString *)email;

@end

@interface GLPVerificationViewController : UIViewController

//@property (assign, nonatomic) BOOL facebookMode;
//@property (strong, nonatomic) NSDictionary *facebookLoginInfo;

@property (weak, nonatomic) UIViewController <GLPVerificationViewControllerDelegate> *delegate;

@end
