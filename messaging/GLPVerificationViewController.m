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

@interface GLPVerificationViewController ()

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

@property (strong, nonatomic) NSString *fbName;


@end

@implementation GLPVerificationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getPendingUsersData];
    [self configureNavigationBar];
    [self configureTitles];
    [self formatElements];
    [self configureDataOnElements];
    [self configureFBData];
}

#pragma mark - Configuration

- (void)configureNavigationBar
{
    self.title = @"SIGN UP";
    [self.navigationController.navigationBar setTextButton:kRight withTitle:@"DONE" withButtonSize:CGSizeMake(75, 17) withColour:[AppearanceHelper greenGleepostColour] withSelector:@selector(loginUserFromLoginScreen:) andTarget:self];
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
}

- (void)getPendingUsersData
{
    self.profileImage = [[GLPTemporaryUserInformationManager sharedInstance] image];
    self.email = [[GLPTemporaryUserInformationManager sharedInstance] email];
    self.password = [[GLPTemporaryUserInformationManager sharedInstance] password];
}

- (void)configureFBData
{
    //Load verification view if the user needs to verified from facebook login.
    if(_facebookLoginInfo)
    {
        _fbName = [_facebookLoginInfo objectForKey:@"Name"];
        self.email = [_facebookLoginInfo objectForKey:@"Email"];
        
        _facebookMode = YES;
    }
    else
    {
        _facebookMode = NO;
    }
}

#pragma mark - Selector

- (IBAction)continueLogin:(id)sender
{
    if(_facebookMode)
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
