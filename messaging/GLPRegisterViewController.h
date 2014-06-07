//
//  GLPRegisterViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 7/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLPRegisterViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

-(NSString *)email;

-(NSString *)password;

-(void)loginUserFromLoginScreen:(BOOL)shouldRemember;

-(BOOL)areEmailPassValid;

-(BOOL)isEmalValid;

-(void)formatTextField:(UITextField*)textField;

-(void)setDefaultTextToEmailAndPassFields;

-(void)uploadImageAndSetUserImage:(UIImage*)userImage;

-(BOOL)isPasswordValid;

-(void)dismissModalView;

- (void)configureNavigationBarForVerificationView;

@end
