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
#import "UIImageView+GLPFormat.h"
#import "LoginView.h"
#import "GLPIntroAnimationHelper.h"
#import "GLPiOSSupportHelper.h"
#import "UINavigationBar+Utils.h"
#import "SignUpView.h"

@interface GLPLoginSignUpViewController () <RegisterViewsProtocol, ImageSelectorViewControllerDelegate>

@property (strong, nonatomic) UIAlertView *emailPromptAlertView;
@property (strong, nonatomic) NSDictionary *fbLoginInfo;
@property (strong, nonatomic) NSString *universityEmail;

@property (weak, nonatomic) IBOutlet UIImageView *gleepostLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *gradientImageView;

@property (weak, nonatomic) IBOutlet RegisterAnimationsView *animationsView;
@property (strong, nonatomic) GLPIntroAnimationHelper *introAnimationHelper;


@property (weak, nonatomic) IBOutlet UILabel *welcomeBackLabel;
@property (weak, nonatomic) IBOutlet LoginView *loginView;
@property (weak, nonatomic) IBOutlet SignUpView *signUpView;
@property (weak, nonatomic) IBOutlet UIImageView *subTitleImageView;

//Constraints

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLogoWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceLogoFromTop;

@end


static NSString * const kCancelButtonTitle   = @"Cancel";
static NSString * const kSignUpButtonTitle   = @"Login";
static NSString * const kOkButtonTitle       = @"Ok";

@implementation GLPLoginSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //If the mode is on development then make the secret change server gesture.
    //Otherwise the server will be on live by default.
    
    if(DEV)
    {
        [self configureGestures];
    }
    
    [self formatImageView];
    [self initialiseObjects];
    [self configureConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self formatStatusBar];
    [self configNavigationBar];
}

#pragma mark - Configuration

- (void)configureConstraints
{
    [self.gleepostLogoImageView layoutIfNeeded];
    [self.topLogoWidth setConstant:[GLPiOSSupportHelper screenWidth] * 0.45];
}

- (void)formatImageView
{
    [self.gradientImageView layoutIfNeeded];
    [self.gradientImageView applyCradientEffect];
}

- (void)initialiseObjects
{
    self.introAnimationHelper = [[GLPIntroAnimationHelper alloc] init];
    [self.loginView setDelegate:self];
    [self.signUpView setDelegate:self];
}

#pragma mark - RegisterViewsProtocol

- (void)loginSignUpError:(ErrorMessage)error
{
    switch (error) {
        case kEmailInvalid:
            [WebClientHelper showStandardEmailError];
            break;
            
            case kTextFieldsEmpty:
            [WebClientHelper showStandardLoginErrorWithMessage:@"It looks like you have left an empty field!"];
            break;
            
        default:
            break;
    }
}

- (void)login
{
    
    if (![self.loginView isEmalValid])
    {
        [self loginSignUpError:kEmailInvalid];
    }
    else if([self.loginView areTextFieldsEmpty])
    {
        [self loginSignUpError:kTextFieldsEmpty];
    }
    else
    {
        DDLogDebug(@"GLPLoginSignUpViewController : Login selector");
        [self loginReady];
    }
    
}

- (void)signUp
{
    DDLogDebug(@"Sign up");
    
    if (![self.signUpView isEmalValid])
    {
        [self loginSignUpError:kEmailInvalid];
    }
    else if([self.signUpView areTextFieldsEmpty])
    {
        [self loginSignUpError:kTextFieldsEmpty];
    }
    else
    {
        DDLogDebug(@"GLPLoginSignUpViewController : SignUp selector");
        [self signUpReady];
    }
}

- (void)selectImage
{
    //Pick an image for sign up view.
    [self performSegueWithIdentifier:@"pick image" sender:self];
}

#pragma mark - ImageSelectorViewControllerDelegate

- (void)takeImage:(UIImage *)image
{
    [self.signUpView selectedImage:image];
}

#pragma mark - Operations

/**
 Called only by the NEXT navigation button.
 */
- (void)loginOrSignUp
{
    if(!self.loginView.hidden)
    {
        [self login];
    }
    else if(!self.signUpView.hidden)
    {
        [self signUp];
    }
    
}

//TODO: Move that to a kind of login manager or improve the currnet one.

- (void)loginReady
{
    [self.loginView startLoading];
    
    [GLPLoginManager loginWithIdentifier:self.loginView.emailTextFieldText andPassword:self.loginView.passwordTextFieldText shouldRemember:NO callback:^(BOOL success, NSString *errorMessage) {
        
        if(success)
        {
            [self performSegueWithIdentifier:@"start" sender:self];
            
        } else {
            
            [self.loginView stopLoading];
            [self.loginView becomePasswordFieldFirstResponder];
            [WebClientHelper showStandardLoginErrorWithMessage:errorMessage];
        }
    }];
}

- (void)signUpReady
{
    
}

#pragma mark - Animation Selectors

- (void)backToMainView
{
    [self.introAnimationHelper moveTopImageBackToTheMiddle:self.gleepostLogoImageView withTopDistanceConstraint:self.distanceLogoFromTop withTopLogoWidth:self.topLogoWidth];
    [self.introAnimationHelper hideRegisterView:self.loginView withWelcomeLabel:self.welcomeBackLabel withSubTitleImageView:self.subTitleImageView];
    [self.introAnimationHelper hideRegisterView:self.signUpView withWelcomeLabel:self.welcomeBackLabel withSubTitleImageView:self.subTitleImageView];
    [self.navigationController.navigationBar clearNavigationItemsWithNavigationController:self];
    [self.loginView resignFieldResponder];
    [self.signUpView resignFieldResponder];
}

- (void)showSignUpView
{
    [self showRegisterView];
    [self.introAnimationHelper showRegisterView:self.signUpView withWelcomeLabel:self.welcomeBackLabel withSubTitleImageView:self.subTitleImageView];
    [self.signUpView becomeFirstNameFirstResponder];
}

- (void)showLoginView
{
    [self showRegisterView];
    [self.introAnimationHelper showRegisterView:self.loginView withWelcomeLabel:self.welcomeBackLabel withSubTitleImageView:self.subTitleImageView];
    [self.loginView becomeEmailFieldFirstResponder];
}

- (void)showRegisterView
{
    [self.navigationController.navigationBar setTextButton:kRight withTitle:@"NEXT" withButtonSize:CGSizeMake(65.0, 22.0) withColour:[UIColor whiteColor] withSelector:@selector(loginOrSignUp) andTarget:self];
    [self.navigationController.navigationBar setButton:kLeft specialButton:kSimple withImageName:@"back_final" withButtonSize:CGSizeMake(33.0, 22.5) withSelector:@selector(backToMainView) andTarget:self];
    [self.introAnimationHelper moveTopImageToTop:self.gleepostLogoImageView withTopDistanceConstraint:self.distanceLogoFromTop withTopLogoWidth:self.topLogoWidth];
}

#pragma mark - Selectors

- (IBAction)facebookLogin:(id)sender
{
    [self registerViaFacebookWithEmailOrNil:nil];
}

- (IBAction)signUp:(id)sender
{
//    _fbLoginInfo = nil;
    [self showSignUpViewController];
//    [self showSignUpView];
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

//    [self showLoginView];
    
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
    else if ([segue.identifier isEqualToString:@"pick image"])
    {
        ImageSelectorViewController *imgSelectorVC = segue.destinationViewController;
        imgSelectorVC.fromGroupViewController = NO;
        [imgSelectorVC setDelegate:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
