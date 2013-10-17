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

@interface FinalRegisterViewController ()

@property (strong, nonatomic) IBOutlet GCPlaceholderTextView *userNameTextView;
@property (strong, nonatomic) IBOutlet GCPlaceholderTextView *genderTextView;
@property (strong, nonatomic) IBOutlet GCPlaceholderTextView *userLastNameTextView;
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
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    
    //	if((UIButton *) sender == choosePhotoBtn) {
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    //	} else {
    //		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //	}
    
    
	//[self presentModalViewController:picker animated:YES];
    
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
	[self.addImageButton setBackgroundImage:[info objectForKey:@"UIImagePickerControllerOriginalImage"] forState:UIControlStateNormal];
}

@end
