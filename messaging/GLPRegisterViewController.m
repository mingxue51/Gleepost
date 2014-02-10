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


@interface GLPRegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;


@end

@implementation GLPRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_emailTextField becomeFirstResponder];
    
    [self formatTextFields];
	// Do any additional setup after loading the view.
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Client

-(void)loginUserFromLoginScreenWithImage:(UIImage*)profileImage
{
    [WebClientHelper showStandardLoaderWithTitle:@"Login" forView:self.view];
    
    [GLPLoginManager loginWithIdentifier:_emailTextField.text andPassword:_passwordTextField.text callback:^(BOOL success) {
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success) {
            if(profileImage)
            {
                [self uploadImageAndSetUserImage:profileImage];
            }
            
            [self performSegueWithIdentifier:@"start" sender:self];
        } else {
            [WebClientHelper showStandardErrorWithTitle:@"Login failed" andContent:@"Check your credentials or your internet connection, dude."];
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
            [WebClientHelper showStandardErrorWithTitle:@"Error uploading the image" andContent:@"Please check your connection and try again"];
            
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
    if(DEV) {
        
        self.emailTextField.text = @"A@kent.ac.uk";
        self.passwordTextField.text = @"1234";

        
//        if(!ON_DEVICE) {
//            //            self.nameTextField.text = @"TestingUser";
//            //            self.passwordTextField.text = @"TestingPass";
//            //            self.nameTextField.text = @"Silouanos N";
//            //            self.passwordTextField.text = @"1234";
//            self.emailTextField.text = @"fingolfin@leeds.ac.uk";
//            self.passwordTextField.text = @"ihatemorgoth";
//        } else {
//            self.emailTextField.text = @"sc11pm@leeds.ac.uk";
//            self.passwordTextField.text = @"TestingPass";
//            //            self.nameTextField.text = @"TestingUser";
//            //            self.passwordTextField.text = @"TestingPass";
//        }
    }
}

#pragma mark - UI formatters

-(void)formatTextField:(UITextField*)textField
{
    CGRect textFieldFrame = textField.frame;
    textFieldFrame.size.height+=5;
    [textField setFrame:textFieldFrame];
    
    [textField setBackgroundColor:[UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f]];
//    [textField setBackground:[UIImage imageNamed:@"email_field"]];
    [textField setTextColor:[UIColor lightGrayColor]];

    textField.layer.borderWidth = 1.0f;
    textField.layer.borderColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f].CGColor;
    
    textField.layer.cornerRadius = 5;
    textField.clipsToBounds = YES;
    
}

-(void)formatTextFields
{
    [self formatTextField:_emailTextField];
    [self formatTextField:_passwordTextField];
}

#pragma mark - Helpers

-(BOOL)areEmailPassValid
{
    return ([ValidFields NSStringIsValidEmail:self.emailTextField.text] && ![self.passwordTextField.text isEqualToString:@""]);

}





@end
