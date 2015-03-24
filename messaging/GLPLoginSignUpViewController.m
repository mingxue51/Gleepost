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
#import "RegisterAnimationsView.h"
#import "SessionManager.h"
#import "UIImageVIew+GLPFormat.h"

@interface GLPLoginSignUpViewController ()

@property (strong, nonatomic) UIAlertView *emailPromptAlertView;
@property (strong, nonatomic) NSDictionary *fbLoginInfo;
@property (strong, nonatomic) NSString *universityEmail;

@property (weak, nonatomic) IBOutlet UIImageView *gleepostLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *gradientImageView;


@property (weak, nonatomic) IBOutlet RegisterAnimationsView *animationsView;

@end


static NSString * const kCancelButtonTitle   = @"Cancel";
static NSString * const kSignUpButtonTitle   = @"Login";
static NSString * const kOkButtonTitle       = @"Ok";

@implementation GLPLoginSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configNavigationBar];
    
    //If the mode is on development then make the secret change server gesture.
    //Otherwise the server will be on live by default.
    
    if(DEV)
    {
        [self configureGestures];
    }
    
    [self formatImageView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self formatStatusBar];
}

- (void)formatImageView
{
    [self.gradientImageView layoutIfNeeded];
    [self.gradientImageView applyCradientEffect];
}

- (IBAction)facebookLogin:(id)sender
{
    [self registerViaFacebookWithEmailOrNil:nil];
}

- (IBAction)signUp:(id)sender
{
    _fbLoginInfo = nil;
    [self showSignUpViewController];
}

- (void)showSignUpViewController
{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iphone_ipad" bundle:nil];
//    GLPSignUpViewController *signUpVC = [storyboard instantiateViewControllerWithIdentifier:@"GLPSignUpViewController"];
    
//    if(_fbLoginInfo)
//    {
//        signUpVC.parentVC = self;
//        signUpVC.facebookLoginInfo = _fbLoginInfo;
//    }
    
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:signUpVC];
//    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
//    [self presentViewController:navigationController animated:YES completion:nil];
    
    [self performSegueWithIdentifier:@"show sign up" sender:self];

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

- (void)configureGestures
{
    if(DEV)
    {
        UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeServerMode:)];
        [tap setMinimumPressDuration:3];
        [tap setNumberOfTapsRequired:0];
        [_gleepostLogoImageView addGestureRecognizer:tap];
    }
}

- (void)changeServerMode:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        [[SessionManager sharedInstance] switchServerMode];
        [WebClientHelper showChangedModeServerMessageWithServerMode:[[SessionManager sharedInstance] serverMode]];

    }
    
}

-(void)formatStatusBar
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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

//TODO: Remove that is it's not used.
-(NSString *)saveLocallyUniversityEmail:(NSString *)email
{
    DDLogDebug(@"saveLocallyUniversityEmail: %@", email);
    
    if(email)
    {
        UICKeyChainStore *store = [UICKeyChainStore keyChainStore];
        [store setString:email forKey:@"facebook.email"];
        [store synchronize];
        
        DDLogDebug(@"E-mail saved: %@", email);
        
        return email;
    }
    else
    {
        DDLogDebug(@"E-mail retrieved: %@", [self loadUniversityEmail]);

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
            [GLPLoginManager loginFacebookUserWithName:name withEmail:email response:response callback:^(BOOL success, NSString *status, NSString *email) {
                
                if (success)
                {
                    [self performSegueWithIdentifier:@"start" sender:self];
                }
                else if([status isEqualToString:@"registered"])
                {
                    //Ask user to put his password.
//                    [self askUserForPassword];
                    _universityEmail = [self saveLocallyUniversityEmail:email];

                    [self askUserForEmailAndPasswordAskAgain:NO];
                }
                else if(!success && [status isEqualToString:@"unverified"])
                {
                    //Pop up the verification view.
                    _fbLoginInfo = [NSDictionary dictionaryWithObjectsAndKeys:name, @"Name", email, @"Email", nil];
                    [self showSignUpViewController];
                    
                }
                else
                {
                    [WebClientHelper facebookLoginErrorWithStatus:status];
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
                [WebClientHelper facebookLoginErrorWithStatus:response];
            }
            else
            {
                NSLog(@"Cannot login through facebook");
                [WebClientHelper showInternetConnectionErrorWithTitle:@"Failed to login with Facebook."];
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

    
    [[GLPFacebookConnect sharedConnection] associateAlreadyRegisteredAccountWithFacebookTokenWithPassword:password andEmail:_universityEmail withCallbackBlock:^(BOOL success) {
        
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
                    [WebClientHelper showInternetConnectionErrorWithTitle:@"Failed to login."];
                }
                
            }];
        }
        else
        {
            
            //Ask again to fill information.
            [self askUserForEmailAndPasswordAskAgain:YES];
            
        }
        
    }];
}

- (void)askUserForEmailAddressAgain:(BOOL)askingAgain
{
    NSString *alertMessage = (askingAgain) ? @"Invalid email address. Please enter your valid university email address to login" : @"Please enter your valid university email address to login";
    
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

-(void)askUserForEmailAndPasswordAskAgain:(BOOL)askAgain
{
    NSString *alertMessage = (!askAgain) ? @"You already signed up with Gleepost, please type your password in order to continue" : @"Authentication failed, please check your e-mail or password and try again";
    
    UIAlertView *passwordPromptAlertView = [[UIAlertView alloc] initWithTitle:@"Password Required"
                                                                      message:alertMessage
                                                                     delegate:self
                                                            cancelButtonTitle:kCancelButtonTitle
                                                            otherButtonTitles:kSignUpButtonTitle, nil];
    
    
    passwordPromptAlertView.tag = 1;
    
    
    [passwordPromptAlertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    if(_universityEmail)
    {
        [[passwordPromptAlertView textFieldAtIndex:0] setText:_universityEmail];

    }
    
    [passwordPromptAlertView show];
}

# pragma mark - UIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    UITextField *textField = ((UITextField*)[alertView textFieldAtIndex:0]);
    return ![NSString isStringEmpty:textField.text];
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    if(alertView.tag == 1)
    {
        if(!_universityEmail)
        {
            UITextField *passwordField = [alertView textFieldAtIndex:1];
            [passwordField becomeFirstResponder];
        }
    }
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
        NSString *email = [alertView textFieldAtIndex:0].text;
        NSString *password = [alertView textFieldAtIndex:1].text;
        
        _universityEmail = email;

        DDLogDebug(@"New email and Pass: %@ : %@", email, password);
        
        
        if ([buttonText isEqualToString:kSignUpButtonTitle])
        {
            //Associate gleepost account with facebook.
            [self associateGleepostAccountWithFacebookWithPassword:password];
        }
    }
    

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"show sign up"])
    {
        GLPSignUpViewController *signUpVC = segue.destinationViewController;
        
        if(_fbLoginInfo)
        {
            signUpVC.parentVC = self;
            signUpVC.facebookLoginInfo = _fbLoginInfo;
        }

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
