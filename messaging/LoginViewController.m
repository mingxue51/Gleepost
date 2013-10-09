//
//  LoginViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "SessionManager.h"
#import "WebClient.h"
#import "AppDelegate.h"
#import "WebClientHelper.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)loginButtonClick:(id)sender;
- (IBAction)viewClicked:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(DEV) {
        self.nameTextField.text = @"TestingUser";
        self.passwordTextField.text = @"TestingPass";
    }
    
    
    
    
   // [[self storyboard] se
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

  //  [self setNeedsStatusBarAppearanceUpdate];
}


//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    NSLog(@"status bar style");
//    return UIStatusBarStyleLightContent;
//}


- (IBAction)loginButtonClick:(id)sender
{
    [WebClientHelper showStandardLoaderWithTitle:@"Login" forView:self.view];
    
    [[WebClient sharedInstance] loginWithName:self.nameTextField.text password:self.passwordTextField.text andCallbackBlock:^(BOOL success) {
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success)
        {
            [self performSegueWithIdentifier:@"start" sender:self];
        } else {
            [WebClientHelper showStandardErrorWithTitle:@"Login failed" andContent:@"Check your credentials or your internet connection, dude."];
        }
    }];
}

- (IBAction)viewClicked:(id)sender
{
    [self hideKeyboardIfDisplayed];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboardIfDisplayed];
    return YES;
}

- (void)hideKeyboardIfDisplayed
{
    if([self.nameTextField isFirstResponder]) {
        [self.nameTextField resignFirstResponder];
    }
    
    if([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue");
}

@end
