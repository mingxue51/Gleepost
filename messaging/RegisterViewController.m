//
//  RegisterViewController.m
//  messaging
//
//  Created by Lukas on 8/29/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "RegisterViewController.h"
#import "WebClient.h"
#import "MBProgressHUD.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)registerButtonClick:(id)sender;
- (IBAction)viewClicked:(id)sender;

@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Change the format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar"] forBarMetrics:UIBarMetricsDefault];

}

- (IBAction)registerButtonClick:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Registration";
    hud.detailsLabelText = @"Please wait few seconds";
    
    WebClient *client = [WebClient sharedInstance];
    [client registerWithName:self.nameTextField.text email:self.emailTextField.text password:self.passwordTextField.text andCallbackBlock:^(BOOL success) {
        [hud hide:YES];
        
        if(success) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration failed"
                                                            message:@"Check your informations or your internet connection, dude."
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
    
    if([self.emailTextField isFirstResponder]) {
        [self.emailTextField resignFirstResponder];
    }
    
    if([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }
}
@end
