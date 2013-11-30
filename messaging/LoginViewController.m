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
    
    
    
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar_trans" forBarMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setShadowImage: [[UIImage alloc] init]];

    
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_trans"] forBarMetrics:UIBarMetricsDefault];
    
    
    
    [self setBackground];
    
    if(DEV) {
        if(!ON_DEVICE) {
//            self.nameTextField.text = @"TestingUser";
//            self.passwordTextField.text = @"TestingPass";
//            self.nameTextField.text = @"Silouanos N";
//            self.passwordTextField.text = @"1234";
            self.nameTextField.text = @"Fingolfin";
            self.passwordTextField.text = @"ihatemorgoth";
        } else {
            self.nameTextField.text = @"TestingUser";
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
