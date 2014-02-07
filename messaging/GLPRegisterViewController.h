//
//  GLPRegisterViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 7/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLPRegisterViewController : UIViewController

-(NSString*)email;

-(NSString*)password;

-(void)loginUserFromLoginScreenWithImage:(UIImage*)profileImage;

-(BOOL)areEmailPassValid;

-(void)formatTextField:(UITextField*)textField;

-(void)setDefaultTextToEmailAndPassFields;

-(void)uploadImageAndSetUserImage:(UIImage*)userImage;


@end
