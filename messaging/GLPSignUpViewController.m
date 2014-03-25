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

@interface GLPSignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *surnameTextField;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (strong, nonatomic) FDTakeController *fdTakeController;

@property (strong, nonatomic) UIImage *finalProfileImage;
@property (weak, nonatomic) IBOutlet UIView *verifyView;
@property (weak, nonatomic) IBOutlet UIView *signUpView;

@property (weak, nonatomic) IBOutlet UILabel *messageLlbl;
@property (weak, nonatomic) IBOutlet UILabel *messageAgainLbl;

@property (strong, nonatomic) NSString *fbName;
@property (assign, nonatomic) BOOL facebookMode;

@end

@implementation GLPSignUpViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self initialiseObjects];
    
    if(!_facebookLoginInfo)
    {
        [self formatElements];
        
    }
}


-(void)setUpMessageLabels
{
    
    [_messageLlbl setText:[NSString stringWithFormat:@"Verification email sent to: %@. Please click on the link in the email to verify that you're at Stanford.",[super email]]];

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


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    DDLogDebug(@"GLPSignUpViewController FB INFO: %@", _facebookLoginInfo);
    
    
    //Load verification view if the user needs to verified from facebook login.
    if(_facebookLoginInfo)
    {
        _fbName = [_facebookLoginInfo objectForKey:@"Name"];
        [super emailTextField].text = [_facebookLoginInfo objectForKey:@"Email"];
        _facebookMode = YES;
        
        [self hideSignUpViewAndShowVerification];
        

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
    
    _fdTakeController = [[FDTakeController alloc] init];
    _fdTakeController.viewControllerForPresentingImagePickerController = self;
    _fdTakeController.delegate = self;
    
    //Add gesture recogniser to profile image view.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickTheImage:)];
    [tap setNumberOfTapsRequired:1];
    [_profileImage addGestureRecognizer:tap];
}

-(void)formatElements
{
    [super formatTextField:_nameTextField];
    
    [super formatTextField:_surnameTextField];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pickTheImage:(id)sender
{
    [_fdTakeController takePhotoOrChooseFromLibrary];

}

#pragma mark - FDTakeController delegate

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)dict
{
    _finalProfileImage = photo;
    [self.profileImage setImage:photo];
    
//    [super uploadImageAndSetUserImage:photo];
    
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
                NSLog(@"User register successful with remote Key: %d", remoteKey);
//                [self performSegueWithIdentifier:@"verify" sender:self];
                
                //Update the image and the image in temporary user information manager.
                [[GLPTemporaryUserInformationManager sharedInstance] setEmail:[super email] andImage:_finalProfileImage];
                
                [self hideSignUpViewAndShowVerification];
                
                //[self loginUser];
            }
            else
            {
                NSLog(@"User not registered.");
                
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
                    [WebClientHelper showStandardErrorWithTitle:@"Oops!" andContent:responseMessage];
                }

                
            }
            
        }];
    }
    else
    {
        [WebClientHelper showStandardErrorWithTitle:@"Please check your information" andContent:@"Please check your provided information and try again."];
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

-(void)loadDataAfterFacebookLoginWithServerResponse:(NSString *)response
{
    //Load data if that's success.
    
    [GLPLoginManager loginFacebookUserWithName:_fbName withEmail:[super emailTextField].text response:response callback:^(BOOL success, NSString *serverResponse) {
        
        if (success)
        {
            [self performSegueWithIdentifier:@"start" sender:self];
        }
        else if(!success && [serverResponse isEqualToString:@"unverified"])
        {
            [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"You still unverified."];
        }
        else
        {
            [WebClientHelper showStandardErrorWithTitle:@"Error" andContent:@"An error occured while loading your data"];
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
        
    }];
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

@end
