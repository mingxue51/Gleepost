//
//  LoginViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "SessionManager.h"
#import "WebClient.h"
#import "AppDelegate.h"
#import "WebClientHelper.h"
#import "AppearanceHelper.h"
#import "GLPLongPollManager.h"
#import "GLPContact.h"
#import "GLPContactDao.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)loginButtonClick:(id)sender;
- (IBAction)viewClicked:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //Change the colour format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    
    
    
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar_trans" forBarMetrics:UIBarMetricsDefault];

    
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_trans"] forBarMetrics:UIBarMetricsDefault];
    
    
    
    [self setBackground];
    
    if(DEV) {
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            self.nameTextField.text = @"Fingolfin";
            self.passwordTextField.text = @"ihatemorgoth";
        } else {
            self.nameTextField.text = @"TestingUser";
            self.passwordTextField.text = @"TestingPass";
        }
    }
    
    
    //Change the height of text filed.
//    CGRect frameRect = _nameTextField.frame;
//    frameRect.size.height = 200;
//    _nameTextField.frame = frameRect;
    
    
    
    
   // [[self storyboard] se
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

  //  [self setNeedsStatusBarAppearanceUpdate];
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


//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    NSLog(@"status bar style");
//    return UIStatusBarStyleLightContent;
//}


- (IBAction)loginButtonClick:(id)sender
{
    [WebClientHelper showStandardLoaderWithTitle:@"Login" forView:self.view];
    
    [[WebClient sharedInstance] loginWithName:self.nameTextField.text password:self.passwordTextField.text andCallbackBlock:^(BOOL success) {
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success) {
            [[GLPLongPollManager sharedInstance] startLongPoll];
            
            //Load contacts and add them to the database.
            [self loadContactsAndSaveToDatabase];
            
            [self performSegueWithIdentifier:@"start" sender:self];
        } else {
            [WebClientHelper showStandardErrorWithTitle:@"Login failed" andContent:@"Check your credentials or your internet connection, dude."];
        }
    }];
}


-(void) loadContactsAndSaveToDatabase
{
    [WebClientHelper showStandardLoaderWithTitle:@"Loading contacts" forView:self.view];
    
    
    [[WebClient sharedInstance ] getContactsWithCallbackBlock:^(BOOL success, NSArray *contacts) {
        
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        
        if(success)
        {
            //GLPUser *user = [[SessionManager sharedInstance] user];
            
            for(GLPContact *contact in contacts)
            {
                [GLPContactDao save:contact];
            }
        }
        else
        {
            [WebClientHelper showStandardError];
        }
        
        
    }];
}

- (IBAction)viewClicked:(id)sender
{
    [self hideKeyboardIfDisplayed];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboardIfDisplayed];
    return YES;
}

- (void)hideKeyboardIfDisplayed
{
    if([self.nameTextField isFirstResponder]) {
        [self.nameTextField resignFirstResponder];
    }
    
    if([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue");
}

@end
