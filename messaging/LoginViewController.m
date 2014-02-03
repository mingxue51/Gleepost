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
#import "GLPLoginManager.h"
#import "UIViewController+GAI.h"
#import "UIViewController+Flurry.h"

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
    
    //Sets colour to navigation items.
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //Set the  colour of navigation bar's title.
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
    
    [self setUpTextFields];
    
    
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar_trans" forBarMetrics:UIBarMetricsDefault];
    
    //Set the  colour of navigation bar's title.
    [AppearanceHelper setFormatForLoginNavigationBar:self];
    
    
    //[[UINavigationBar appearance] setShadowImage: [[UIImage alloc] init]];

    
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_trans"] forBarMetrics:UIBarMetricsDefault];
    
    
    
    [self setBackground];
    
    if(DEV) {
        if(!ON_DEVICE) {
//            self.nameTextField.text = @"TestingUser";
//            self.passwordTextField.text = @"TestingPass";
//            self.nameTextField.text = @"Silouanos N";
//            self.passwordTextField.text = @"1234";
            self.nameTextField.text = @"fingolfin@leeds.ac.uk";
            self.passwordTextField.text = @"ihatemorgoth";
        } else {
            self.nameTextField.text = @"sc11pm@leeds.ac.uk";
            self.passwordTextField.text = @"TestingPass";
//            self.nameTextField.text = @"TestingUser";
//            self.passwordTextField.text = @"TestingPass";
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self sendViewToGAI:NSStringFromClass([self class])];
    [self sendViewToFlurry:NSStringFromClass([self class])];
}


-(void)setUpTextFields
{
    CGRect textFielFrame = self.nameTextField.frame;
    textFielFrame.size.height+=10;
    [self.nameTextField setFrame:textFielFrame];
    [self.nameTextField setBackgroundColor:[UIColor whiteColor]];
    [self.nameTextField setTextColor:[UIColor blackColor]];
    self.nameTextField.layer.cornerRadius = 20;
    self.nameTextField.layer.borderColor = [UIColor colorWithRed:28.0f/255.0f green:208.0f/255.0f blue:208.f/255.0f alpha:1.0f].CGColor;
    self.nameTextField.layer.borderWidth = 3.0f;
    self.nameTextField.clipsToBounds = YES;
    
    
    textFielFrame = self.passwordTextField.frame;
    textFielFrame.size.height+=10;
    [self.passwordTextField setFrame:textFielFrame];
    [self.passwordTextField setBackgroundColor:[UIColor whiteColor]];
    [self.passwordTextField setTextColor:[UIColor blackColor]];
    self.passwordTextField.layer.cornerRadius = 20;
    self.passwordTextField.layer.borderColor = [UIColor colorWithRed:28.0f/255.0f green:208.0f/255.0f blue:208.f/255.0f alpha:1.0f].CGColor;
    self.passwordTextField.layer.borderWidth = 3.0f;
    self.passwordTextField.clipsToBounds = YES;
}

-(void) setBackground
{
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImage *newChatImage = [UIImage imageNamed:@"background_login_pages"];
    
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
    
    [GLPLoginManager loginWithIdentifier:self.nameTextField.text andPassword:self.passwordTextField.text callback:^(BOOL success) {
        [WebClientHelper hideStandardLoaderForView:self.view];
        
        if(success) {
            [self performSegueWithIdentifier:@"start" sender:self];
        } else {
            [WebClientHelper showStandardErrorWithTitle:@"Login failed" andContent:@"Check your credentials or your internet connection, dude."];
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

@end
