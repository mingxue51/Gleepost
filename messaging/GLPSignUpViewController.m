//
//  GLPSignUpViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 7/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPSignUpViewController.h"
#import "WebClientHelper.h"
#import "WebClient.h"
#import "GLPLoginManager.h"
#import "GLPTemporaryUserInformationManager.h"
#import "GLPFacebookConnect.h"
#import "ShapeFormatterHelper.h"
#import "UIColor+GLPAdditions.h"
#import "UINavigationBar+Utils.h"

@interface GLPSignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *surnameTextField;
//@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
//@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundProfileImage;

@property (strong, nonatomic) UIImage *finalProfileImage;
@property (weak, nonatomic) IBOutlet UIView *verifyView;
@property (weak, nonatomic) IBOutlet UIView *signUpView;

@property (weak, nonatomic) IBOutlet UILabel *messageLlbl;
@property (weak, nonatomic) IBOutlet UILabel *messageAgainLbl;

@property (strong, nonatomic) NSString *fbName;
@property (assign, nonatomic) BOOL facebookMode;
@property (weak, nonatomic) IBOutlet UIButton *wrongEmailFbLogin;

@end

@implementation GLPSignUpViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initialiseObjects];
    
    if(!_facebookLoginInfo)
    {
        [self formatElements];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    [self configureViews];
    
    if(![_nameTextField isFirstResponder] && !_facebookMode)
    {
        [_nameTextField becomeFirstResponder];
    }
    else if(_facebookMode)
    {
        //        [_nameTextField resignFirstResponder];
        [[super emailTextField] resignFirstResponder];
    }
}

- (void)configureNavigationBar
{
    [super configureNavigationBar];
    [self.navigationController.navigationBar setTextButton:kRight withTitle:@"NEXT" withButtonSize:CGSizeMake(50.0, 17.0) withColour:[UIColor whiteColor] withSelector:@selector(navigateToTheNextSignUpView) andTarget:self];
}

-(void)setUpMessageLabels
{
    [_messageLlbl setText:[NSString stringWithFormat:@"We have sent you an email to: %@ to verify that this is your email address.", [super email]]];
}

-(void)showErrorVerifyUser
{
    [_messageAgainLbl setTextColor:[UIColor redColor]];
    
    [_messageAgainLbl setText:[NSString stringWithFormat:@"No you're not. Are your sure your're at Stanford?"]];
}

-(void)showResendMessage
{
    [_messageAgainLbl setTextColor:[UIColor blackColor]];

    [_messageAgainLbl setText:[NSString stringWithFormat:@"We've sent you another verification email to: %@",[super email]]];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
//    if(![_nameTextField isFirstResponder] && !_facebookMode)
//    {
//        [_nameTextField becomeFirstResponder];
//    }
//    else
//    {
////        [self hideKeyboard];
//    }
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
//    [_nameTextField becomeFirstResponder];

    [super viewWillDisappear:animated];
}

-(void)configureViews
{
    
    //Load verification view if the user needs to verified from facebook login.
    if(_facebookLoginInfo)
    {
        _fbName = [_facebookLoginInfo objectForKey:@"Name"];
        [super emailTextField].text = [_facebookLoginInfo objectForKey:@"Email"];
    
        _facebookMode = YES;
        
        [self hideSignUpViewAndShowVerificationAfterFBLogin];
        

//        [_signUpView setHidden:YES];
//        [_verifyView setHidden:NO];
    }
    else
    {
        _facebookMode = NO;
    }
}

-(void)initialiseObjects
{
    _finalProfileImage = nil;
    
    //Add gesture recogniser to profile image view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickTheImage:)];
    [tap setNumberOfTapsRequired:1];
    [_profileImage addGestureRecognizer:tap];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickTheImage:)];
    [tap setNumberOfTapsRequired:1];
    [_backgroundProfileImage addGestureRecognizer:tap];
}

-(void)formatElements
{
    [super formatTextField:_nameTextField];
    
    [super formatTextField:_surnameTextField];
    
    [self formatPickImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag == 1)
    {
        [self.emailTextField becomeFirstResponder];
    }
    else if(textField.tag == 2)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField.tag == 3)
    {
        //TODO: Go to the next view.
    }
    
    return NO;
}

#pragma mark - ImageSelectorViewControllerDelegate

- (void)takeImage:(UIImage *)image
{
    _finalProfileImage = image;
    [self.profileImage setImage:nil];
    [self.backgroundProfileImage setImage:image];
}

#pragma mark - Client

- (IBAction)registerUser:(id)sender
{
    //Check e-mail.
    
    if(![super isEmalValid])
    {
        [WebClientHelper showStandardEmailError];
        
        return;
    }
    
    //Check password.
    
    if(![super isPasswordValid])
    {
        [WebClientHelper showStandardPasswordError];
        
        return;
        
    }
    
    if([self.nameTextField.text isEqualToString:@""])
    {
        [WebClientHelper showStandardFirstNameError];
        
        return;
    }
    
    if([self.surnameTextField.text isEqualToString:@""])
    {
        [WebClientHelper showStandardLastNameError];
        
        return;
    }
    
    if(!_finalProfileImage)
    {
        [WebClientHelper showStandardProfileImageError];
        
        return;
    }
    
    if([self areTheDetailsValid])
    {
        DDLogDebug(@"Values: %@ %@ %@ %@",_nameTextField.text ,_surnameTextField.text ,[super email] ,[super password]);
        
        [WebClientHelper showStandardLoaderWithTitle:@"Registering" forView:self.view];
        
        [[WebClient sharedInstance] registerWithName:_nameTextField.text surname:_surnameTextField.text email:[super email] password:[super password] andCallbackBlock:^(BOOL success, NSString *responseMessage, int remoteKey) {
            
            [WebClientHelper hideStandardLoaderForView:self.view];
            
            if(success)
            {
                //Navigate to home.
                DDLogInfo(@"User register successful with remote Key: %d", remoteKey);
//                [self performSegueWithIdentifier:@"verify" sender:self];
                
                //Update the image and the image in temporary user information manager.
                [[GLPTemporaryUserInformationManager sharedInstance] setEmail:[super email] andImage:_finalProfileImage];
                
                [self hideSignUpViewAndShowVerification];
                
                //[self loginUser];
            }
            else
            {
                DDLogInfo(@"User not registered.");
                
                if ([responseMessage rangeOfString:@"Invalid Email"].location != NSNotFound)
                {
                    [WebClientHelper showStandardEmailError];
                }
                else if([responseMessage rangeOfString:@"Missing parameter: first"].location != NSNotFound)
                {
                    [WebClientHelper showStandardFirstNameTooShortError];
                }
                else
                {
                    [WebClientHelper errorRegisteringUserWithResponse:responseMessage];
                }
            }
        }];
    }
    else
    {
        [WebClientHelper errorWrongCredentials];
    }
}

-(IBAction)loginUser:(id)sender
{
    if(_facebookMode)
    {
//        DDLogDebug(@"Facebook info: %@ : %@ :%@ Token: %@", _fbName, _fbResponse, [super emailTextField].text, [[GLPFacebookConnect sharedConnection] facebookLoginToken]);
        
        //Login user and get from server the token and the remote key.
        //If this code reached means that the user is unverified.
        
        [[WebClient sharedInstance] registerViaFacebookToken:[[GLPFacebookConnect sharedConnection] facebookLoginToken] withEmailOrNil:[super emailTextField].text andCallbackBlock:^(BOOL success, NSString *responseObject) {
            
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
        [super loginUserFromLoginScreen:NO];
    }
    
    
//    
//    [WebClientHelper showStandardLoaderWithTitle:@"Login" forView:self.view];
//    
//    [GLPLoginManager loginWithIdentifier:[super email] andPassword:[super password] callback:^(BOOL success, NSString *errorMessage) {
//        [WebClientHelper hideStandardLoaderForView:self.view];
//        
//        if(success) {
//            if(_profileImage.image)
//            {
//                [self uploadImageAndSetUserImage:_profileImage.image];
//            }
//            
//            [self performSegueWithIdentifier:@"start" sender:self];
//        } else {
//            [self showErrorVerifyUser];
//        }
//    }];
}

- (void)pickTheImage:(id)sender
{
    [self performSegueWithIdentifier:@"pick image" sender:self];
}

-(void)loadDataAfterFacebookLoginWithServerResponse:(NSString *)response
{
    //Load data if that's success.
    
    [GLPLoginManager loginFacebookUserWithName:_fbName withEmail:[super emailTextField].text response:response callback:^(BOOL success, NSString *serverResponse, NSString *email) {
        
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

- (IBAction)resendVerification:(id)sender
{
    [WebClientHelper showStandardLoaderWithTitle:@"Resending verification email" forView:self.view];
    
    [[WebClient sharedInstance] resendVerificationToEmail:[super email] andCallbackBlock:^(BOOL success) {
        
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success)
        {
            [self showResendMessage];

        }
        else
        {
            [self showErrorVerifyUser];
        }
        
    }];

}
/**
 User send action to this method only in case he type wrong
 credentials during facebook login.
 */
- (IBAction)retypeEmailAndPass:(id)sender
{
    [self.parentVC askUserForEmailAddressAgain:NO];
    [super dismissModalView];
}

#pragma mark - Format

- (void)formatPickImage
{
    [ShapeFormatterHelper setBorderToView:_backgroundProfileImage withColour:[UIColor colorWithR:227.0 withG:227.0 andB:227.0] andWidth:1.5f];
    [ShapeFormatterHelper setCornerRadiusWithView:_backgroundProfileImage andValue:4];
}

#pragma mark - UI methods

-(void)hideSignUpViewAndShowVerification
{
    [_verifyView setAlpha:0.0f];
    [_verifyView setHidden:NO];
    
    [UIView animateWithDuration:1.0f animations:^{
        
        [_verifyView setAlpha:1.0f];
        
        [_signUpView setAlpha:0.0f];
        
        
        [self hideKeyboard];
        
        [self setUpMessageLabels];
        
        [self showMinimiseButton];
        
    }];
}

-(void)hideSignUpViewAndShowVerificationAfterFBLogin
{
    [self hideSignUpViewAndShowVerification];
    
    [_wrongEmailFbLogin setHidden:NO];
    
}

- (void)showMinimiseButton
{
    [super configureNavigationBarForVerificationView];
}

-(void)hideKeyboard
{
    [self.view endEditing:YES];
}

-(void)hideView:(UIView*)view
{
    [view setAlpha:0.0f];
    [view setHidden:YES];
}

-(void)showView:(UIView*)view
{
    [view setHidden:NO];

    [view setAlpha:1.0f];
}

#pragma mark - Helper methods

-(BOOL)areTheDetailsValid
{
    return (![_nameTextField.text isEqualToString:@""] && ![_surnameTextField.text isEqualToString:@""] && (_profileImage!=nil) && [super areEmailPassValid]);
}

#pragma mark - Navigation

- (void)navigateToTheNextSignUpView
{
    [self performSegueWithIdentifier:@"show sign up second" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"pick image"])
    {
        ImageSelectorViewController *imgSelectorVC = segue.destinationViewController;
        imgSelectorVC.fromGroupViewController = NO;
        [imgSelectorVC setDelegate:self];
    }
}

@end
