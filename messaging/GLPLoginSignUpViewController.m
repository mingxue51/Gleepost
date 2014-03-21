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
@property (strong, nonatomic) NSString *fbEmail;

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
    
    DDLogInfo(@"Text field: %@", textField);
    
    BOOL shouldReturn = NO;
    NSString *universityEmail = textField.text;
    
    if ([NSString isStringEmpty:universityEmail]) {
        
        [self registerViaFacebookWithEmailOrNil:universityEmail];
        
        
        //TODO: Save university e-mail to a plist file in case user kill the app.
//        [self saveLocallyUniversityEmail:universityEmail];
        
        
        [_emailPromptAlertView dismissWithClickedButtonIndex:-1 animated:YES];
        
        shouldReturn = YES;
    }
    
    return shouldReturn;
}

-(void)saveLocallyUniversityEmail:(NSString *)email
{
    UICKeyChainStore *store = [UICKeyChainStore keyChainStore];
    [store setString:email forKey:@"user.email"];
    [store synchronize];
}

#pragma mark - Facebook login

- (void)registerViaFacebookWithEmailOrNil:(NSString *)email {
    [WebClientHelper showStandardLoaderWithTitle:@"Logging in" forView:self.view];
    DDLogDebug(@"EMAIL!: %@",email);
    
    __weak GLPLoginSignUpViewController *weakSelf = self;
    [[GLPFacebookConnect sharedConnection] openSessionWithEmailOrNil:email completionHandler:^(BOOL success, NSString *name, NSString *response) {
        
        [WebClientHelper hideStandardLoaderForView:weakSelf.view];
        
        if (success)
        {
            NSLog(@"logged in successfully via facebook with response: %@", response);
            
            [GLPLoginManager loginFacebookUserWithName:name response:response callback:^(BOOL success, NSString *serverResponse) {
                
                if (success)
                {
                    [weakSelf performSegueWithIdentifier:@"start" sender:weakSelf];
                }
                else if(!success && [serverResponse isEqualToString:@"unverified"])
                {
                    //Pop up the verification view.
                    _fbLoginInfo = [NSDictionary dictionaryWithObjectsAndKeys:name, @"Name", response, @"Response", email, @"Email", nil];
                    [weakSelf performSegueWithIdentifier:@"show signup" sender:weakSelf];
                    
                }
                else
                {
                    [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occured while loading your data"];
                }
            }];
                        #warning TODO: add segue in storyboard!
        } else
        {
            DDLogDebug(@"logged in not successfully via facebook with response: %@", response);
            
            if ([response rangeOfString:@"Email is required"].location != NSNotFound)
            {
                NSLog(@"University Email id required for Facebook Login");
                [weakSelf askUserForEmailAddressAgain:NO];
                
            } else if ([response rangeOfString:@"Invalid email"].location != NSNotFound)
            {
                NSLog(@"Wrong email address entered");
                [weakSelf askUserForEmailAddressAgain:YES];
                
            } else
            {
                NSLog(@"Cannot login through facebook");
                [WebClientHelper showStandardError];
            }
        }
    }];
}

- (void)askUserForEmailAddressAgain:(BOOL)askingAgain {
    NSString *alertMessage = (askingAgain) ? @"Invalid email address. Please enter your valid university email address to sign up" : @"Please enter your valid university email address to sign up";
    
    _emailPromptAlertView = [[UIAlertView alloc] initWithTitle:@"Email Required"
                                                       message:alertMessage
                                                      delegate:self
                                             cancelButtonTitle:kCancelButtonTitle
                                             otherButtonTitles:kSignUpButtonTitle, nil];
    
    [_emailPromptAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [_emailPromptAlertView textFieldAtIndex:0];
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    
    [_emailPromptAlertView show];
}


# pragma mark - UIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    UITextField *textField = ((UITextField*)[alertView textFieldAtIndex:0]);
    return ![NSString isStringEmpty:textField.text];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:-1 animated:YES];
    
    NSString *buttonText = [alertView buttonTitleAtIndex:buttonIndex];
    NSString *universityEmail = [alertView textFieldAtIndex:0].text;
    
    if ([buttonText isEqualToString:kSignUpButtonTitle])
        [self registerViaFacebookWithEmailOrNil:universityEmail];
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
