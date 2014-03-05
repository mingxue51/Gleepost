//
//  VerificationViewController.m
//  Gleepost
//
//  Created by Silouanos on 04/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "VerificationViewController.h"
#import "GLPLoginManager.h"
#import "WebClientHelper.h"
#import "WebClient.h"
#import "ImageFormatterHelper.h"
#import "GLPUserDao.h"
#import "SessionManager.h"
#import "AppearanceHelper.h"

@interface VerificationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *messageLlbl;


@end

@implementation VerificationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [AppearanceHelper setFormatForLoginNavigationBar:self];

    [self setUpMessageLabel];
}

-(void)setUpMessageLabel
{
    [_messageLlbl setText:[NSString stringWithFormat:@"Verification email sent to: %@. Please click on the link in the email to verify that you're at Stanford.",self.eMailPass[0]]];
}

-(void)uploadImageAndSetUserImageWithUserRemoteKey:(int)remoteKey
{
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
    
    [GLPLoginManager loginWithIdentifier:self.eMailPass[0] andPassword:self.eMailPass[1] shouldRemember:NO callback:^(BOOL success, NSString *errorMessage) {
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

#pragma mark - Selectors

- (IBAction)login:(id)sender
{
    [self loginUser];
}

- (IBAction)resendVerification:(id)sender
{
    [WebClientHelper showStandardLoaderWithTitle:@"Resending verification email" forView:self.view];
    
    [[WebClient sharedInstance] resendVerificationToEmail:self.eMailPass[0] andCallbackBlock:^(BOOL success) {
       
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
