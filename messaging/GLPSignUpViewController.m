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

@interface GLPSignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *surnameTextField;

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (strong, nonatomic) FDTakeController *fdTakeController;

@property (strong, nonatomic) UIImage *finalProfileImage;
@property (weak, nonatomic) IBOutlet UIView *verifyView;
@property (weak, nonatomic) IBOutlet UIView *signUpView;

@property (weak, nonatomic) IBOutlet UILabel *messageLlbl;


@end

@implementation GLPSignUpViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initialiseObjects];
    
    [self formatElements];
}


-(void)setUpMessageLabel
{
    
    [_messageLlbl setText:[NSString stringWithFormat:@"Verification email sent to: %@. Please click on the link in the email to verify that you're at Stanford.",[super email]]];
}

//TODO: Issue with keyboard.

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![_nameTextField isFirstResponder])
    {
        [_nameTextField becomeFirstResponder];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(![_nameTextField isFirstResponder])
    {
        [_nameTextField becomeFirstResponder];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
//    [_nameTextField becomeFirstResponder];

    [super viewWillDisappear:animated];
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
                [self hideSignUpViewAndShowVerification];
                
                //[self loginUser];
            }
            else
            {
                NSLog(@"User not registered.");
                [WebClientHelper showStandardErrorWithTitle:@"Authentication Failed" andContent:responseMessage];
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
    [super loginUserFromLoginScreenWithImage:_profileImage.image];
}

- (IBAction)resendVerification:(id)sender
{
    [WebClientHelper showStandardLoaderWithTitle:@"Resending verification email" forView:self.view];
    
    [[WebClient sharedInstance] resendVerificationToEmail:[super email] andCallbackBlock:^(BOOL success) {
        
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success)
        {
            [WebClientHelper showStandardErrorWithTitle:@"Email verification sent" andContent:@"Please check your email and try to login in."];
        }
        else
        {
            [WebClientHelper showInternetConnectionErrorWithTitle:@"Failed to resend verification email"];
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
        
        [self setUpMessageLabel];
        
    }];
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
