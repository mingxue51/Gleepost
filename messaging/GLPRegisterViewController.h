//
//  GLPRegisterViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 7/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLPRegisterViewController : UIViewController <UITextFieldDelegate>

-(NSString*)email;

-(NSString*)password;

//-(void)loginUserFromLoginScreenWithImage:(UIImage*)profileImage;

-(void)loginUserFromLoginScreen;


-(BOOL)areEmailPassValid;

-(BOOL)isEmalValid;

-(void)formatTextField:(UITextField*)textField;

-(void)setDefaultTextToEmailAndPassFields;

-(void)uploadImageAndSetUserImage:(UIImage*)userImage;

-(BOOL)isPasswordValid;

@end
