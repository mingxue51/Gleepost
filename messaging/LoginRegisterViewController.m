//
//  LoginRegisterViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 16/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "LoginRegisterViewController.h"
#import "AppearanceHelper.h"
#import "FBSession.h"
#import "GLPFacebookConnect.h"
#import "WebClientHelper.h"
#import "GLPLoginManager.h"
#import "NSString+Utils.h"


@interface LoginRegisterViewController () <UITextFieldDelegate, UIAlertViewDelegate> {
    UIAlertView *_emailPromptAlertView;
}

@end

static NSString * const kCancelButtonTitle   = @"Cancel";
static NSString * const kSignUpButtonTitle   = @"Sign Up";
static NSString * const kOkButtonTitle       = @"Ok";

@implementation LoginRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Change the colour format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar_trans" forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    
    
    [self setBackground];
    
    [self setImages];
}

- (IBAction)loginWithFacebook
{
    [self registerViaFacebookWithEmailOrNil:nil];
}

- (IBAction)gleepostSignUp:(id)sender
{
    [self performSegueWithIdentifier:@"register" sender:self];
}

- (IBAction)signIn:(id)sender
{
    [self performSegueWithIdentifier:@"login" sender:self];
}

-(void)setImages
{
    
}

-(void) setBackground
{
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImage *newChatImage = [UIImage imageNamed:@"new_chat_background"];
    
    UIImageView *backgroundImage = [[UIImageView alloc] init];
    
    [backgroundImage setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    backgroundImage.image = newChatImage;
    
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Email Required AlertView
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

# pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = NO;
    NSString *universityEmail = textField.text;
    
    if ([NSString isStringEmpty:universityEmail]) {
        [self registerViaFacebookWithEmailOrNil:universityEmail];
        
        [_emailPromptAlertView dismissWithClickedButtonIndex:-1 animated:YES];
        
        shouldReturn = YES;
    }
    
    return shouldReturn;
}

# pragma mark - UIAlertViewDelegate
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    UITextField *textField = ((UITextField*)[alertView textFieldAtIndex:0]);
    return [NSString isStringEmpty:textField.text];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:-1 animated:YES];

    NSString *buttonText = [alertView buttonTitleAtIndex:buttonIndex];
    NSString *universityEmail = [alertView textFieldAtIndex:0].text;
    
    if ([buttonText isEqualToString:kSignUpButtonTitle])
        [self registerViaFacebookWithEmailOrNil:universityEmail];
}

# pragma mark - Helper methods
- (void)registerViaFacebookWithEmailOrNil:(NSString *)email {
    [WebClientHelper showStandardLoaderWithTitle:@"Logging in" forView:self.view];
    
    __weak LoginRegisterViewController *weakSelf = self;
    [[GLPFacebookConnect sharedConnection] openSessionWithEmailOrNil:email completionHandler:^(BOOL success, NSString *name, NSString *response) {
        [WebClientHelper hideStandardLoaderForView:weakSelf.view];
        
        if (success) {
            NSLog(@"logged in successfully via facebook");
            [GLPLoginManager loginFacebookUserWithName:name response:response callback:^(BOOL success) {
                if (success)    [weakSelf performSegueWithIdentifier:@"start" sender:weakSelf];
                else            [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occured while loading your data"];
            }];
            #warning TODO: add segue in storyboard!
        } else {
            if ([response rangeOfString:@"Email is required"].location != NSNotFound) {
                NSLog(@"University Email id required for Facebook Login");
                [weakSelf askUserForEmailAddressAgain:NO];
            } else if ([response rangeOfString:@"Invalid email"].location != NSNotFound) {
                NSLog(@"Wrong email address entered");
                [weakSelf askUserForEmailAddressAgain:YES];
            } else {
                NSLog(@"Cannot login through facebook");
                [WebClientHelper showStandardError];
            }
        }
    }];
}

@end
