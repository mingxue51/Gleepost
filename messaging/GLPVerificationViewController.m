//
//  GLPVerificationViewController.m
//  Gleepost
//
//  Created by Silouanos on 27/03/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPVerificationViewController.h"
#import "UINavigationBar+Utils.h"
#import "UINavigationBar+Format.h"
#import "AppearanceHelper.h"
#import "GLPTemporaryUserInformationManager.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "GLPLoginManager.h"
#import "GLPFacebookConnect.h"
#import "ShapeFormatterHelper.h"

@interface GLPVerificationViewController () <UIAlertViewDelegate>

//Read only variables.
@property (strong, nonatomic, readonly) NSString *verificationTitle;
@property (strong, nonatomic, readonly) NSString *verificationSubtitle;

//Comes from previews view variables.
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) UIImage *profileImage;

@property (weak, nonatomic) IBOutlet UILabel *verificationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *verificationSubtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *changeEmailActivityIndicator;

@property (strong, nonatomic) NSString *fbName;


@end

NSString *kVerificationSignUpButtonTitle   = @"Login";
NSString *kVerificationCancelButtonTitle = @"Cancel";

@implementation GLPVerificationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getPendingUsersData];
    [self configureNavigationBar];
    [self configureTitles];
    [self formatElements];
    [self configureDataOnElements];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailChanged) name:GLPNOTIFICATION_UPDATE_EMAIL_TO_VERIFICATION_VIEW object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_UPDATE_EMAIL_TO_VERIFICATION_VIEW object:nil];
    
    [super viewDidDisappear:animated];
}

#pragma mark - Configuration

- (void)configureNavigationBar
{
    self.title = @"SIGN UP";
    [self.navigationController.navigationBar setTextButton:kRight withTitle:@"DONE" withButtonSize:CGSizeMake(75, 17) withColour:[AppearanceHelper greenGleepostColour] withSelector:@selector(continueLogin:) andTarget:self];
    [self.navigationController.navigationBar setFontFormatWithColour:kBlack];
    [self.navigationController.navigationBar whiteTranslucentBackgroundFormatWithShadow:YES andView:self.view];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)configureTitles
{
    _verificationTitle = @"We've sent a verification email to: ";
    _verificationSubtitle = @"Click on the link in the email to verify that you go to ";
}

- (void)formatElements
{
    [ShapeFormatterHelper setBorderToView:self.profileImageView withColour:[AppearanceHelper grayGleepostColour] andWidth:1.0];
    [self.profileImageView layoutIfNeeded];
    [ShapeFormatterHelper setRoundedView:self.profileImageView toDiameter:self.profileImageView.frame.size.height];
}

- (void)configureDataOnElements
{
    [self.profileImageView setImage:[[GLPTemporaryUserInformationManager sharedInstance] image]];
    [self.verificationTitleLabel setText:[NSString stringWithFormat:@"%@%@", self.verificationTitle, [[GLPTemporaryUserInformationManager sharedInstance] email]]];
    [self.verificationSubtitleLabel setText:[NSString stringWithFormat:@"%@%@", self.verificationSubtitle, [[GLPTemporaryUserInformationManager sharedInstance] university]]];
}

- (void)getPendingUsersData
{
    self.profileImage = [[GLPTemporaryUserInformationManager sharedInstance] image];
    self.email = [[GLPTemporaryUserInformationManager sharedInstance] email];
    self.password = [[GLPTemporaryUserInformationManager sharedInstance] password];
    self.fbName = [[GLPTemporaryUserInformationManager sharedInstance] name];
}

#pragma mark - UIAlertView

- (void)askUserForEmailAddressAgain
{
    NSString *alertMessage = @"Please enter your valid university email address to login";
    
     UIAlertView *emailPromptAlertView = [[UIAlertView alloc] initWithTitle:@"Email Required"
                                                       message:alertMessage
                                                      delegate:self
                                             cancelButtonTitle:kVerificationCancelButtonTitle
                                             otherButtonTitles:kVerificationSignUpButtonTitle, nil];
    
    
    [emailPromptAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [emailPromptAlertView textFieldAtIndex:0];
    textField.returnKeyType = UIReturnKeyDone;
//    textField.delegate = self;
    
    [emailPromptAlertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:-1 animated:YES];
    
    NSString *buttonText = [alertView buttonTitleAtIndex:buttonIndex];

    if([buttonText isEqualToString:kVerificationSignUpButtonTitle])
    {
        self.email = [alertView textFieldAtIndex:0].text;
        [self.delegate changeEmailAfterFacebookLogin:self.email];
    }
}

#pragma mark - NSNotification methods

- (void)emailChanged
{
    [self showLabelsAndStopLoading];
    [self configureDataOnElements];
}

#pragma mark - Selector

- (IBAction)continueLogin:(id)sender
{
    if([GLPTemporaryUserInformationManager sharedInstance].facebookMode)
    {
        //        DDLogDebug(@"Facebook info: %@ : %@ :%@ Token: %@", _fbName, _fbResponse, [super emailTextField].text, [[GLPFacebookConnect sharedConnection] facebookLoginToken]);
        
        //Login user and get from server the token and the remote key.
        //If this code reached means that the user is unverified.

        [[WebClient sharedInstance] registerViaFacebookToken:[[GLPFacebookConnect sharedConnection] facebookLoginToken] withEmailOrNil:self.email andCallbackBlock:^(BOOL success, NSString *responseObject) {
            
            if(success)
            {
                [self loadDataAfterFacebookLoginWithServerResponse:responseObject];
            }
            else
            {
                DDLogError(@"Failed to register to facebook.");
            }
            
        }];
    }
    else
    {
        [self loginUserFromLoginScreen:NO];
    }
}

- (IBAction)resendVerification:(id)sender
{
    [[WebClient sharedInstance] resendVerificationToEmail:self.email andCallbackBlock:^(BOOL success) {
        
        if(success)
        {
            [WebClientHelper verificationResent];
            
        }
        else
        {
            [WebClientHelper errorUnverifiedUser];
        }
        
    }];
}

/**
 User send action to this method only in case he type wrong
 credentials during facebook login or user put wrong password.
 */
- (IBAction)retypeEmailAndPass:(id)sender
{
    if(self.delegate)
    {
        [self hideLabelsAndStartLoading];
        //Prompt a pop up and ask for email.
        [self askUserForEmailAddressAgain];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Helpers

- (void)hideLabelsAndStartLoading
{
    [self.verificationTitleLabel setHidden:YES];
    [self.verificationSubtitleLabel setHidden:YES];
    [self.changeEmailActivityIndicator startAnimating];

}

- (void)showLabelsAndStopLoading
{
    [self.verificationTitleLabel setHidden:NO];
    [self.verificationSubtitleLabel setHidden:NO];
    [self.changeEmailActivityIndicator stopAnimating];
}

#pragma mark - Login client

-(void)loginUserFromLoginScreen:(BOOL)shouldRemember
{
    
    [GLPLoginManager loginWithIdentifier:self.email andPassword:self.password shouldRemember:shouldRemember callback:^(BOOL success, NSString *errorMessage) {
        
        if(success) {
            
            
            if([[GLPTemporaryUserInformationManager sharedInstance] informationExistWithEmail:self.email])
            {
                [GLPLoginManager uploadImageAndSetUserImage:[[GLPTemporaryUserInformationManager sharedInstance] image]];
            }
            
            [self performSegueWithIdentifier:@"start" sender:self];
            
        } else {
            
            [WebClientHelper showStandardLoginErrorWithMessage:errorMessage];
        }
    }];
}

-(void)loadDataAfterFacebookLoginWithServerResponse:(NSString *)response
{
    //Load data if that's success.
    
    [GLPLoginManager loginFacebookUserWithName:_fbName withEmail:self.email response:response callback:^(BOOL success, NSString *serverResponse, NSString *email) {
        
        if (success)
        {
            [self performSegueWithIdentifier:@"start" sender:self];
        }
        else if(!success && [serverResponse isEqualToString:@"unverified"])
        {
            [WebClientHelper errorUnverifiedUser];
        }
        else
        {
            [WebClientHelper errorLoadingData];
        }
    }];
}


@end
