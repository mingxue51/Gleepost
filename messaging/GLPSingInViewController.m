//
//  GLPSingInViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 6/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPSingInViewController.h"
#import "WebClientHelper.h"
#import "GLPLoginManager.h"
#import "WebClient.h"
#import "UICKeyChainStore.h"
#import "UINavigationBar+Utils.h"
#import "AppearanceHelper.h"

@interface GLPSingInViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *simpleNavBar;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *rememberMeButton;

@property (assign, nonatomic) BOOL shouldRememberMe;

- (IBAction)rememberMeButtonClick:(id)sender;

@end

@implementation GLPSingInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [super setDefaultTextToEmailAndPassFields];
    
    [self configureRememberMe];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)configureNavigationBar
{
    [super configureNavigationBar];
    
    self.title = @"LOG IN";
    
    [self.navigationController.navigationBar setTextButton:kRight withTitle:@"DONE" withButtonSize:CGSizeMake(50, 17) withColour:[AppearanceHelper greenGleepostColour] withSelector:@selector(login:) andTarget:self];
}

- (void)configureRememberMe
{
    _shouldRememberMe = [GLPLoginManager isUserRemembered];
    [self updateRememberMe];
    
    if(_shouldRememberMe) {
        self.emailTextField.text = [UICKeyChainStore stringForKey:@"user.email"];
        [self.emailTextField resignFirstResponder];
        
        if([GLPLoginManager shouldAutoLogin]) {
            self.passwordTextField.text = [UICKeyChainStore stringForKey:@"user.password"];
            [self.passwordTextField resignFirstResponder];
            
            [super loginUserFromLoginScreen:YES];
        } else {
            [self.passwordTextField becomeFirstResponder];
        }
    }
}

- (void)updateRememberMe
{
    UIImage *selectedImage = [UIImage imageNamed:@"login_checkbox_checked"];
    UIImage *unselectedImage = [UIImage imageNamed:@"login_checkbox_unchecked"];
    
    UIImage *current, *opposite;
    
    if(_shouldRememberMe) {
        current = selectedImage;
        opposite = unselectedImage;
    } else {
        current = unselectedImage;
        opposite = selectedImage;
    }
    
    [_rememberMeButton setImage:current forState:UIControlStateNormal];
    [_rememberMeButton setImage:opposite forState:UIControlStateHighlighted];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag == 1)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else if(textField.tag == 2)
    {
        [self login:textField];
    }
    
    return NO;
}

#pragma mark - Actions

- (IBAction)login:(id)sender
{
    [super loginUserFromLoginScreen:_shouldRememberMe];
}

- (IBAction)rememberMeButtonClick:(id)sender
{
    _shouldRememberMe = !_shouldRememberMe;
    [self updateRememberMe];
}



// What is that ?!
//TODO: Call this method.

//-(void)configureNavigationBar
//{
////    [self.simpleNavBar setBackgroundColor:[UIColor clearColor]];
//    
//    [self.simpleNavBar setTranslucent:NO];
//    [self.simpleNavBar setFrame:CGRectMake(0.f, 0.f, 320.f, 100.f)];
//    self.simpleNavBar.tintColor = [UIColor whiteColor];
//    
//    [self.simpleNavBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor,[UIFont fontWithName:GLP_APP_FONT size:20.0f], UITextAttributeFont, nil]];
//}


- (IBAction)forgotPassword:(id)sender
{
    if([self isEmalValid])
    {
        [WebClientHelper showStandardLoaderWithTitle:@"Sending email" forView:self.view];
        
        //Communicate with server to send verification to email.
        [[WebClient sharedInstance] resetPasswordWithEmail:[self email] callbackBlock:^(BOOL success) {
            
            [WebClientHelper hideStandardLoaderForView:self.view];
            
            if(success)
            {
                [WebClientHelper showRecoveryEmailMessage:self.email];
            }
            else
            {
                [WebClientHelper failedToSendEmailResettingPassword];
            }
            
        }];
    }
    else
    {
        [WebClientHelper showStandardEmailError];
    }
}


@end
