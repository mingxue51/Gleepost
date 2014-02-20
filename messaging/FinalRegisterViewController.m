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
#import "UIViewController+Flurry.h"
#import "GLPUserDao.h"
#import "ShapeFormatterHelper.h"
#import "AppearanceHelper.h"
#import "VerificationViewController.h"

@interface FinalRegisterViewController ()

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *userNameTextView;
@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *userLastNameTextView;
@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *genderTextView;

@property (weak, nonatomic) IBOutlet UITextField *tagLineTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;


@property (strong, nonatomic) FDTakeController *fdTakeController;
@property (strong, nonatomic) UIImage *profileImage;

- (IBAction)pickAnImage:(id)sender;

@end

@implementation FinalRegisterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    //Change the colour format of the navigation bar.=
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [AppearanceHelper setFormatForLoginNavigationBar:self];
    
    [self setBackground];
    
    [self setUpTextFields];
    
    [self formatElements];
    
    self.profileImage = nil;
    
    self.fdTakeController = [[FDTakeController alloc] init];
    self.fdTakeController.viewControllerForPresentingImagePickerController = self;
    self.fdTakeController.delegate = self;
    
    


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
        
    [self.tagLineTextField becomeFirstResponder];
    
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}

-(void)formatElements
{
    //Add corner radius to image  view.
    [ShapeFormatterHelper setCornerRadiusWithView:self.addImageView andValue:10.0f];
    
    
    //Add gesture to select image view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickAnImage:)];
    [tap setNumberOfTapsRequired:1];
    [self.addImageView addGestureRecognizer:tap];
}

-(void)setUpTextFields
{
    CGRect textFielFrame = self.tagLineTextField.frame;
    textFielFrame.size.height+=10;
    [self.tagLineTextField setFrame:textFielFrame];
    [self.tagLineTextField setBackgroundColor:[UIColor whiteColor]];
    [self.tagLineTextField setTextColor:[UIColor blackColor]];
    self.tagLineTextField.layer.cornerRadius = 20;
    self.tagLineTextField.layer.borderColor = [UIColor colorWithRed:28.0f/255.0f green:208.0f/255.0f blue:208.f/255.0f alpha:1.0f].CGColor;
    self.tagLineTextField.layer.borderWidth = 3.0f;
    self.tagLineTextField.clipsToBounds = YES;
}

-(void)setUpTextViews
{
    
    CGRect textFielFrame = self.tagLineTextField.frame;
    textFielFrame.size.height+=5;
    [self.tagLineTextField setFrame:textFielFrame];
    [self.tagLineTextField setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2]];
    [self.tagLineTextField setTextColor:[UIColor whiteColor]];
    self.tagLineTextField.layer.cornerRadius = 10;
    self.tagLineTextField.clipsToBounds = YES;
    
    textFielFrame = self.lastNameTextField.frame;
    textFielFrame.size.height+=5;
    [self.lastNameTextField setFrame:textFielFrame];
    [self.lastNameTextField setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2]];
    [self.lastNameTextField setTextColor:[UIColor whiteColor]];
    self.lastNameTextField.layer.cornerRadius = 10;
    self.lastNameTextField.clipsToBounds = YES;
    
    textFielFrame = self.genderTextField.frame;
    textFielFrame.size.height+=5;
    [self.genderTextField setFrame:textFielFrame];
    [self.genderTextField setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2]];
    [self.genderTextField setTextColor:[UIColor whiteColor]];
    self.genderTextField.layer.cornerRadius = 10;
    self.genderTextField.clipsToBounds = YES;
    
    
    
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
    
    if([self.tagLineTextField isFirstResponder])
    {
        [self.tagLineTextField resignFirstResponder];
    }
    
    if([self.lastNameTextField isFirstResponder])
    {
        [self.lastNameTextField resignFirstResponder];
    }
    
    if([self.genderTextField isFirstResponder])
    {
        [self.genderTextField resignFirstResponder];
    }
    
    
    
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
    if([self areTheDetailsValid])
    {
        //Request to server to register user.
//        [[WebClient sharedInstance] registerWithName:[NSString stringWithFormat:@"%@ %@",self.tagLineTextField.text, self.lastNameTextField.text] email:self.eMailPass[0] password:self.eMailPass[1] andCallbackBlock:^(BOOL success, NSString* responseMessage, int remoteKey) {
//            
//            if(success)
//            {
//                //Navigate to home.
//                NSLog(@"User register successful with remote Key: %d", remoteKey);
//                [self loginUser];
//            }
//            else
//            {
//                NSLog(@"User not registered.");
//                [WebClientHelper showStandardErrorWithTitle:@"Authentication Failed" andContent:responseMessage];
//            }
//            
//        }];
        
        [WebClientHelper showStandardLoaderWithTitle:@"Registering" forView:self.view];
        
        [[WebClient sharedInstance] registerWithName:self.firstLastName[0] surname:self.firstLastName[1] email:self.eMailPass[0] password:self.eMailPass[1] andCallbackBlock:^(BOOL success, NSString *responseMessage, int remoteKey) {
           
            [WebClientHelper hideStandardLoaderForView:self.view];

            if(success)
            {
                //Navigate to home.
                NSLog(@"User register successful with remote Key: %d", remoteKey);
                [self performSegueWithIdentifier:@"verify" sender:self];
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


-(void)loginUser
{
    [WebClientHelper showStandardLoaderWithTitle:@"Login" forView:self.view];
    
    [GLPLoginManager loginWithIdentifier:self.eMailPass[0] andPassword:self.eMailPass[1] callback:^(BOOL success, NSString *errorMessage) {
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success) {
            [self uploadImageAndSetUserImageWithUserRemoteKey:0];
            [self performSegueWithIdentifier:@"start" sender:self];
        } else {
//            [WebClientHelper showStandardErrorWithTitle:@"Login failed" andContent:@"Check your credentials or your internet connection, dude."];
        }
    }];  
}

-(void)setBackground
{
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImage *newChatImage = [UIImage imageNamed:@"background_login_pages"];
    
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VerificationViewController *verificationController = segue.destinationViewController;
    
    verificationController.eMailPass = self.eMailPass;
    
    verificationController.profileImage = self.profileImage;
    
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
    return (![self.tagLineTextField.text isEqualToString:@""] && (self.profileImage!=nil));
}

@end
