//
//  FinalRegisterViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 16/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "FinalRegisterViewController.h"
#import "MBProgressHUD.h"
#import "WebClient.h"
#import "GCPlaceholderTextView.h"
#import "WebClientHelper.h"
#import "WebClient.h"
#import "LoginViewController.h"
#import "SessionManager.h"
#import "ImageFormatterHelper.h"
#import "GLPLoginManager.h"
#import "UIViewController+GAI.h"

@interface FinalRegisterViewController ()

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *userNameTextView;
@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *genderTextView;
@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *userLastNameTextView;
@property (strong, nonatomic) FDTakeController *fdTakeController;
@property (strong, nonatomic) UIImage *profileImage;

- (IBAction)pickAnImage:(id)sender;

@end

@implementation FinalRegisterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    //Change the colour format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [self setBackground];
    
    [self setUpTextViews];
    
    self.profileImage = nil;
    
    self.fdTakeController = [[FDTakeController alloc] init];
    self.fdTakeController.viewControllerForPresentingImagePickerController = self;
    self.fdTakeController.delegate = self;
    
    
    //Add gesture to select image view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickAnImage:)];
    [tap setNumberOfTapsRequired:1];
    [self.addImageView addGestureRecognizer:tap];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self sendViewToGAI:NSStringFromClass([self class])];
}

-(void)setUpTextViews
{
    self.userNameTextView.placeholder = @"First Name";
    self.userNameTextView.textColor = [UIColor whiteColor];
    [self.userNameTextView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_field"]]];
    self.userNameTextView.layer.cornerRadius = 5;
    self.userNameTextView.clipsToBounds = YES;
    
    self.userLastNameTextView.placeholder = @"Last Name";
    self.userLastNameTextView.textColor = [UIColor whiteColor];
    [self.userLastNameTextView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_field"]]];
    self.userLastNameTextView.layer.cornerRadius = 5;
    self.userLastNameTextView.clipsToBounds = YES;
    
    
    self.genderTextView.placeholder = @"Gender";
    self.genderTextView.textColor = [UIColor whiteColor];
    [self.genderTextView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_field"]]];
    self.genderTextView.layer.cornerRadius = 5;
    self.genderTextView.clipsToBounds = YES;
}


- (IBAction)viewTouched:(id)sender
{
    [self hideKeyboardIfDisplayed];
}

- (void)hideKeyboardIfDisplayed
{
    if([self.userNameTextView isFirstResponder])
    {
        [self.userNameTextView resignFirstResponder];
    }
    
    if([self.userLastNameTextView isFirstResponder])
    {
        [self.userLastNameTextView resignFirstResponder];
    }
    
    if([self.genderTextView isFirstResponder])
    {
        [self.genderTextView resignFirstResponder];
    }

}

#pragma mark - Server requests

- (IBAction)registerUser:(id)sender
{
    //TODO: Set user image as a requirement.
    
    if([self areTheDetailsValid])
    {
        //Request to server to register user.
        [[WebClient sharedInstance] registerWithName:[NSString stringWithFormat:@"%@ %@",self.userNameTextView.text, self.userLastNameTextView.text] email:self.eMailPass[0] password:self.eMailPass[1] andCallbackBlock:^(BOOL success, NSString* responceMessage, int remoteKey) {
            
            if(success)
            {
                //Navigate to home.
                NSLog(@"User register successful with remote Key: %d", remoteKey);
                [self loginUser];
            }
            else
            {
                NSLog(@"User not registered.");
                [WebClientHelper showStandardErrorWithTitle:@"Authentication Failed" andContent:responceMessage];
            }
            
        }];
        
        
    }
    else
    {
        [WebClientHelper showStandardErrorWithTitle:@"Please Check your details" andContent:@"Please check your details if are valid."];
    }
}

-(void)uploadImageAndSetUserImageWithUserRemoteKey:(int)remoteKey
{
    //UIImage* imageToUpload = [self resizeImage:self.profileImage WithSize:CGSizeMake(124, 124)];
    UIImage* imageToUpload = [ImageFormatterHelper imageWithImage:self.profileImage scaledToHeight:320];
    
    NSData *imageData = UIImagePNGRepresentation(imageToUpload);
    
    NSLog(@"Image register image size: %d",imageData.length);
    
    
    //[WebClientHelper showStandardLoaderWithTitle:@"Uploading image" forView:self.view];
    
    
    [[WebClient sharedInstance] uploadImage:imageData ForUserRemoteKey:remoteKey callbackBlock:^(BOOL success, NSString* response) {
        
        //[WebClientHelper hideStandardLoaderForView:self.view];
        
        
        if(success)
        {
            NSLog(@"IMAGE UPLOADED. URL: %@",response);
            
            //Set image to user's profile.

            [self setImageToUserProfile:response];
            
            [[SessionManager sharedInstance]user].profileImageUrl = response;
            
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


-(void)loginUser
{
    [WebClientHelper showStandardLoaderWithTitle:@"Login" forView:self.view];
    
    [GLPLoginManager loginWithIdentifier:[NSString stringWithFormat:@"%@ %@",self.userNameTextView.text,self.userLastNameTextView.text] andPassword:self.eMailPass[1] callback:^(BOOL success) {
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success) {
            [self uploadImageAndSetUserImageWithUserRemoteKey:0];
            [self performSegueWithIdentifier:@"start" sender:self];
        } else {
            [WebClientHelper showStandardErrorWithTitle:@"Login failed" andContent:@"Check your credentials or your internet connection, dude."];
        }
    }];
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


//- (IBAction)registerButtonClick:(id)sender
//{
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.labelText = @"Registration";
//    hud.detailsLabelText = @"Please wait few seconds";
//    
//    WebClient *client = [WebClient sharedInstance];
//    [client registerWithName:self.nameTextField.text email:self.emailTextField.text password:self.passwordTextField.text andCallbackBlock:^(BOOL success) {
//        [hud hide:YES];
//        
//        if(success) {
//            [self.navigationController popViewControllerAnimated:YES];
//        } else {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration failed"
//                                                            message:@"Check your informations or your internet connection, dude."
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
//        }
//    }];
//    
//}

//TODO: Create the opportunity to the user to capture live photo.w

- (IBAction)pickAnImage:(id)sender
{
    [self.fdTakeController takePhotoOrChooseFromLibrary];
    
//    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
//	picker.delegate = self;
//    
//    //	if((UIButton *) sender == choosePhotoBtn) {
//    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//    //	} else {
//    //		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    //	}
//    
//    
//	//[self presentModalViewController:picker animated:YES];
//    
//    [self presentViewController:picker animated:YES completion:^{
//        
//    }];
}

#pragma mark - FDTakeController delegate

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)in
{
    self.profileImage = photo;
    [self.addImageView setImage:photo];
    
}


//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    
//    [picker dismissViewControllerAnimated:YES completion:^{
//        
//    }];
//    
//	[self.addImageButton setBackgroundImage:[info objectForKey:@"UIImagePickerControllerOriginalImage"] forState:UIControlStateNormal];
//}

#pragma mark - Other methods


-(BOOL)areTheDetailsValid
{
    return (![self.userNameTextView.text isEqualToString:@""] && ![self.userLastNameTextView.text isEqualToString:@""] && ![self.genderTextView.text isEqualToString:@""] && (self.profileImage!=nil));
}

@end
