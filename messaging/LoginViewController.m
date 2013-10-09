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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Login...";
    hud.detailsLabelText = @"Please wait";
    
    WebClient *client = [WebClient sharedInstance];
    NSLog(@"%@ %@", self.nameTextField.text, self.passwordTextField.text);
    [client loginWithName:self.nameTextField.text password:self.passwordTextField.text andCallbackBlock:^(BOOL success) {
        [hud hide:YES];
        
        if(success)
        {
            [self performSegueWithIdentifier:@"start" sender:self];
            
        } else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login failed"
                                                            message:@"Check your identifiers or your internet connection, dude."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
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
