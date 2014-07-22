//
//  GLPRegisterViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 7/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
// Super class of GLPSignUpViewController and GLPSigninViewController

#import "GLPRegisterViewController.h"
#import "WebClientHelper.h"
#import "GLPLoginManager.h"
#import "ValidFields.h"
#import "WebClient.h"
#import "ImageFormatterHelper.h"
#import "SessionManager.h"
#import "GLPUserDao.h"
#import "GLPTemporaryUserInformationManager.h"
#import "AppearanceHelper.h"
#import "UIColor+GLPAdditions.h"
#import "IntroSegue.h"

@interface GLPRegisterViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *simpleNavigationBar;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation GLPRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_emailTextField becomeFirstResponder];
    
    [self formatTextFields];
    
    [self configureNavigationBar];
    
    [self formatStatusBar];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selectors

- (IBAction)dismissModalView:(id)sender
{
    [self dismissModalView];
}

-(void)dismissModalView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Client

-(void)loginUserFromLoginScreen:(BOOL)shouldRemember
{
    UIView *view = [[UIApplication sharedApplication] windows][1];
    [WebClientHelper showStandardLoaderWithTitle:@"Login" forView:view];
    
    [GLPLoginManager loginWithIdentifier:_emailTextField.text andPassword:_passwordTextField.text shouldRemember:shouldRemember callback:^(BOOL success, NSString *errorMessage) {
        
        [WebClientHelper hideStandardLoaderForView:view];
        
        if(success) {
            
//            if(profileImage)
//            {
//                [self uploadImageAndSetUserImage:profileImage];
//            }
            
            if([[GLPTemporaryUserInformationManager sharedInstance] informationExistWithEmail:_emailTextField.text])
            {
                [self uploadImageAndSetUserImage:[[GLPTemporaryUserInformationManager sharedInstance] image]];
            }

            [self.view endEditing:YES];
            
            [self performSegueWithIdentifier:@"start" sender:self];

            
        } else {
            
            [WebClientHelper showStandardLoginErrorWithMessage:errorMessage];
        }
    }];
}



-(void)uploadImageAndSetUserImage:(UIImage*)userImage
{
    //UIImage* imageToUpload = [self resizeImage:self.profileImage WithSize:CGSizeMake(124, 124)];
    UIImage* imageToUpload = [ImageFormatterHelper imageWithImage:userImage scaledToHeight:320];
    
    NSData *imageData = UIImagePNGRepresentation(imageToUpload);
    
    NSLog(@"Image register image size: %d",imageData.length);
    
    
    //[WebClientHelper showStandardLoaderWithTitle:@"Uploading image" forView:self.view];
    
    
    [[WebClient sharedInstance] uploadImage:imageData ForUserRemoteKey:0 callbackBlock:^(BOOL success, NSString* response) {
        
        //[WebClientHelper hideStandardLoaderForView:self.view];
        
        
        if(success)
        {
            NSLog(@"IMAGE UPLOADED. URL: %@",response);
            
            //Set image to user's profile.
            
            [self setImageToUserProfile:response];
            
            //            [[SessionManager sharedInstance]user].profileImageUrl = response;
            
            
            //Save user's image to database and add to SessionManager.
            //TODO: REFACTOR / FACTORIZE THIS
            GLPUser *user = [SessionManager sharedInstance].user;
            user.profileImageUrl = response;
            [GLPUserDao updateUserWithRemotKey:user.remoteKey andProfileImage:response];
            
        }
        else
        {
            NSLog(@"ERROR");
            [WebClientHelper showStandardError];
            
        }
    }];
}

-(void)setImageToUserProfile:(NSString*)url
{
    NSLog(@"READY TO ADD IMAGE TO USER WITH URL: %@",url);
    
    [[WebClient sharedInstance] uploadImageToProfileUser:url callbackBlock:^(BOOL success) {
        
        if(success)
        {
            NSLog(@"NEW PROFILE IMAGE UPLOADED");
        }
        else
        {
            NSLog(@"ERROR: Not able to register image for profile.");
        }
    }];
}

#pragma mark - Accessors

-(NSString*)password
{
    return _passwordTextField.text;
}

-(NSString*)email
{
    return _emailTextField.text;
}

#pragma mark - Modifiers

-(void)setDefaultTextToEmailAndPassFields
{
//    if(DEV) {
//        if([GLP_WEBSERVICE_VERSION floatValue] < 1.0) {
//            if(!ON_DEVICE) {
//                self.emailTextField.text = @"fingolfin@leeds.ac.uk";
//                self.passwordTextField.text = @"ihatemorgoth";
//            } else {
//                self.emailTextField.text = @"sc11pm@leeds.ac.uk";
//                self.passwordTextField.text = @"TestingPass";
//            }
//        } else {
//            if(ON_DEVICE) {
//                self.emailTextField.text = @"gleepost@stanford.edu";
//                self.passwordTextField.text = @"TestingPass";
//            } else {
//                self.emailTextField.text = @"gleepost123@stanford.edu";
//                self.passwordTextField.text = @"TestingPass";
//            }
//        }
//    }
}

#pragma mark - UI formatters

-(void)formatTextField:(UITextField*)textField
{
    CGRect textFieldFrame = textField.frame;
    textFieldFrame.size.height+=5;
    [textField setFrame:textFieldFrame];
    [textField setBackgroundColor:[UIColor clearColor]];
    [textField setTextColor:[AppearanceHelper colourForRegisterTextFields]];
    textField.borderStyle = UITextBorderStyleNone;
    textField.clipsToBounds = YES;
    textField.delegate = self;
}

-(void)formatTextFields
{
    [self formatTextField:_emailTextField];
    [self formatTextField:_passwordTextField];
}

-(void)configureNavigationBar
{
    
//    [AppearanceHelper setNavigationBarFontForNavigationBar:_simpleNavigationBar];
    
    [_simpleNavigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_new_post"]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    
    [_simpleNavigationBar setShadowImage:[ImageFormatterHelper generateOnePixelHeightImageWithColour:[UIColor colorWithR:227.0 withG:227.0 andB:227.0]]];
}

- (void)configureNavigationBarForVerificationView
{
    [_backButton setImage:[UIImage imageNamed:@"verification_minimize"] forState:UIControlStateNormal];
    
    _simpleNavigationBar.topItem.title = @"Almost done!";
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Helpers

-(BOOL)areEmailPassValid
{
    return ([ValidFields NSStringIsValidEmail:self.emailTextField.text] && ![self.passwordTextField.text isEqualToString:@""]);

}

-(BOOL)isEmalValid
{
    if ([self.emailTextField.text rangeOfString:@".edu"].location == NSNotFound && [self.emailTextField.text rangeOfString:@"gleepost.com"].location == NSNotFound)
    {
        return NO;
        
    } else
    {
        return [ValidFields NSStringIsValidEmail:self.emailTextField.text];
    }
    
}

-(BOOL)isPasswordValid
{
    NSString *pass = self.passwordTextField.text;
    
    if(pass.length < 5)
    {
        return NO;
    }
    
    return YES;
}

-(void)formatStatusBar
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

// Prepare for the segue going forward
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if([segue isKindOfClass:[FadeInCustomSegue class]]) {
//        // Set the start point for the animation to center of the button for the animation
//        ((FadeInCustomSegue *)segue).originatingPoint = _backButton.center;
//    }
//}

@end
