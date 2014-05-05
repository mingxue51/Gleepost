//
//  GLPLoginSignUpViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 6/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
// New temporary login register view controller for a fast implementation.
// The actual design remains in the storyboard.

#import "GLPLoginSignUpViewController.h"
#import "AppearanceHelper.h"
#import "WebClientHelper.h"
#import "GLPFacebookConnect.h"
#import "GLPLoginManager.h"
#import "NSString+Utils.h"
#import "GLPSignUpViewController.h"
#import "UICKeyChainStore.h"

@interface GLPLoginSignUpViewController ()

@property (strong, nonatomic) UIAlertView *emailPromptAlertView;
@property (strong, nonatomic) NSDictionary *fbLoginInfo;
@property (strong, nonatomic) NSString *universityEmail;

@end


static NSString * const kCancelButtonTitle   = @"Cancel";
static NSString * const kSignUpButtonTitle   = @"Sign Up";
static NSString * const kOkButtonTitle       = @"Ok";

@implementation GLPLoginSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configNavigationBar];
}

- (IBAction)facebookLogin:(id)sender
{
    [self registerViaFacebookWithEmailOrNil:nil];
}

- (IBAction)signUp:(id)sender
{
    _fbLoginInfo = nil;
    [self performSegueWithIdentifier:@"show signup" sender:self];
}

- (IBAction)signIn:(id)sender
{
    [self performSegueWithIdentifier:@"show signin" sender:self];
}

#pragma mark - Configuration

-(void)configNavigationBar
{
//    [self.navigationController setNavigationBarHidden:YES];
    //Change the colour format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar_trans" forBarMetrics:UIBarMetricsDefault];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

# pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    BOOL shouldReturn = NO;
    NSString *universityEmail = textField.text;
    
    if ([NSString isStringEmpty:universityEmail]) {
        
        [self registerViaFacebookWithEmailOrNil:universityEmail];
        
        
        //Save university e-mail to a plist file in case user kill the app.
        [self saveLocallyUniversityEmail:universityEmail];
        
        
        [_emailPromptAlertView dismissWithClickedButtonIndex:-1 animated:YES];
        
        shouldReturn = YES;
    }
    
    return shouldReturn;
}

-(NSString *)saveLocallyUniversityEmail:(NSString *)email
{
    DDLogDebug(@"saveLocallyUniversityEmail: %@", email);
    
    if(email)
    {
        UICKeyChainStore *store = [UICKeyChainStore keyChainStore];
        [store setString:email forKey:@"facebook.email"];
        [store synchronize];
        
        return email;
    }
    else
    {
        return [self loadUniversityEmail];
    }
}

-(NSString *)loadUniversityEmail
{
    return [UICKeyChainStore stringForKey:@"facebook.email"];
}

#pragma mark - Facebook login

- (void)registerViaFacebookWithEmailOrNil:(NSString *)email
{
    [WebClientHelper showStandardLoaderWithTitle:@"Logging in" forView:self.view];
    
    email = [self saveLocallyUniversityEmail:email];
    _universityEmail = email;
//    
//    //If user's email is not locally saved or user didn't type it prompt a window to add his email.
//    if(!email)
//    {
//        NSLog(@"University Email id required for Facebook Login");
//
//        [self askUserForEmailAddressAgain:NO];
//
//        
//        return;
//    }
    
    
    [[GLPFacebookConnect sharedConnection] openSessionWithEmailOrNil:email completionHandler:^(BOOL success, NSString *name, NSString *response) {
        
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if (success)
        {
            [GLPLoginManager loginFacebookUserWithName:name withEmail:email response:response callback:^(BOOL success, NSString *serverResponse) {
                
                if (success)
                {
                    [self performSegueWithIdentifier:@"start" sender:self];
                }
                else if([serverResponse isEqualToString:@"registered"])
                {
                    //Ask user to put his password.
                    [self askUserForPassword];
                }
                else if(!success && [serverResponse isEqualToString:@"unverified"])
                {
                    //Pop up the verification view.
                    _fbLoginInfo = [NSDictionary dictionaryWithObjectsAndKeys:name, @"Name", email, @"Email", nil];
                    [self performSegueWithIdentifier:@"show signup" sender:self];
                    
                }
                else
                {
                    [WebClientHelper showStandardErrorWithTitle:@"Facebook Login Error" andContent:serverResponse];
                }
            }];
            
        } else
        {
            DDLogDebug(@"logged in not successfully via facebook: %@", response);
            
            if ([response rangeOfString:@"Email is required"].location != NSNotFound)
            {
                NSLog(@"University Email id required for Facebook Login");
                [self askUserForEmailAddressAgain:NO];
                
            } else if ([response rangeOfString:@"Invalid email"].location != NSNotFound)
            {
                NSLog(@"Wrong email address entered");
                [self askUserForEmailAddressAgain:YES];
                
            } else if([response rangeOfString:@"To use your Facebook account"].location != NSNotFound)
            {
                [WebClientHelper showStandardErrorWithTitle:@"Facebook Login Error" andContent:response];
            }
            else
            {
                NSLog(@"Cannot login through facebook");
                [WebClientHelper showStandardError];
            }
        }
    }];
}

/**
 Called after user typed his password.
 This method associates gleepost account with facebook account and then tries to login to the app
 using user's credentials.
 
 @password user's password
 
 */
-(void)associateGleepostAccountWithFacebookWithPassword:(NSString *)password
{
    [WebClientHelper showStandardLoaderWithTitle:@"Associating account with facebook" forView:self.view];

    
    [[GLPFacebookConnect sharedConnection] associateAlreadyRegisteredAccountWithFacebookTokenWithPassword:password withCallbackBlock:^(BOOL success) {
       
        [WebClientHelper hideStandardLoaderForView:self.view];

        if(success)
        {
            //Login user.
            [GLPLoginManager loginWithIdentifier:_universityEmail andPassword:password shouldRemember:NO callback:^(BOOL success, NSString *errorMessage) {
                
                if(success)
                {
                    [self performSegueWithIdentifier:@"start" sender:self];
                }
                else
                {
                    [WebClientHelper showStandardError];
                }
                
            }];
        }
        else
        {
            [WebClientHelper showStandardErrorWithTitle:@"Association Error" andContent:@"There was a problem associating your account with facebook."];
        }
        
    }];
}

- (void)askUserForEmailAddressAgain:(BOOL)askingAgain
{
    NSString *alertMessage = (askingAgain) ? @"Invalid email address. Please enter your valid university email address to sign up" : @"Please enter your valid university email address to sign up";
    
    _emailPromptAlertView = [[UIAlertView alloc] initWithTitle:@"Email Required"
                                                       message:alertMessage
                                                      delegate:self
                                             cancelButtonTitle:kCancelButtonTitle
                                             otherButtonTitles:kSignUpButtonTitle, nil];
    
    _emailPromptAlertView.tag = 0;
    
    [_emailPromptAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [_emailPromptAlertView textFieldAtIndex:0];
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    
    [_emailPromptAlertView show];
}

/**
 Call this method in case the user is already sign up via regular way.
 Asking for password in order to authenticate the user.
 */
-(void)askUserForPassword
{
    NSString *alertMessage = @"You already signed up with Gleepost, please type your password in order to continue";
    
    UIAlertView *passwordPromptAlertView = [[UIAlertView alloc] initWithTitle:@"Password Required"
                                                                      message:alertMessage
                                                                     delegate:self
                                                            cancelButtonTitle:kCancelButtonTitle
                                                            otherButtonTitles:kSignUpButtonTitle, nil];
    
    passwordPromptAlertView.tag = 1;
    
    [passwordPromptAlertView setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    
    

    [passwordPromptAlertView show];
}


# pragma mark - UIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    UITextField *textField = ((UITextField*)[alertView textFieldAtIndex:0]);
    return ![NSString isStringEmpty:textField.text];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [alertView dismissWithClickedButtonIndex:-1 animated:YES];
    
    NSString *buttonText = [alertView buttonTitleAtIndex:buttonIndex];

    if(alertView.tag == 0)
    {
        //E-mail alert view.
        NSString *universityEmail = [alertView textFieldAtIndex:0].text;
        
        if ([buttonText isEqualToString:kSignUpButtonTitle])
        {
            [self registerViaFacebookWithEmailOrNil:universityEmail];
        }
    }
    else
    {
        //Password alert view.
        NSString *password = [alertView textFieldAtIndex:0].text;
        
        if ([buttonText isEqualToString:kSignUpButtonTitle])
        {
            //Associate gleepost account with facebook.
            [self associateGleepostAccountWithFacebookWithPassword:password];
        }
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"show signup"])
    {
        GLPSignUpViewController *signUpVC = segue.destinationViewController;
        
        signUpVC.facebookLoginInfo = _fbLoginInfo;
        
    }
}

@end
