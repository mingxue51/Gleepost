//
//  RegisterViewController.m
//  messaging
//
//  Created by Lukas on 8/29/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "RegisterViewController.h"
#import "WebClient.h"
#import "MBProgressHUD.h"
#import "AppearanceHelper.h"
#import "GCPlaceholderTextView.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet GCPlaceholderTextView *emailTextView;
@property (strong, nonatomic) IBOutlet GCPlaceholderTextView *passwordTextView;

- (IBAction)viewClicked:(id)sender;

@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"RegisterViewController");
    
    //Change the colour format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    
  //  [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_trans"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];

    
   //[AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar_trans" forBarMetrics:UIBarMetricsDefault];
    

    [self setBackground];
    
    [self setUpTextViews];

    

}

-(void)setUpTextViews
{
    self.emailTextView.placeholder = @"e-mail";
    [self.emailTextView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_field"]]];
    [self.emailTextView setTextColor:[UIColor whiteColor]];
    self.emailTextView.layer.cornerRadius = 5;
    self.emailTextView.clipsToBounds = YES;
    
    
    self.passwordTextView.placeholder = @"password";
    [self.passwordTextView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_field"]]];
    self.passwordTextView.textColor = [UIColor whiteColor];
    self.passwordTextView.layer.cornerRadius = 5;
    self.passwordTextView.clipsToBounds = YES;
}

- (IBAction)finalRegistrationForm:(id)sender
{
    [self performSegueWithIdentifier:@"final registration" sender:self];
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


-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    
    return YES;
}


- (IBAction)viewClicked:(id)sender
{
    NSLog(@"View Clicked.");
    [self hideKeyboardIfDisplayed];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboardIfDisplayed];
    return YES;
}

- (void)hideKeyboardIfDisplayed
{

    if([self.emailTextView isFirstResponder])
    {
        [self.emailTextView resignFirstResponder];
    }
    
    if([self.passwordTextView isFirstResponder])
    {
        [self.passwordTextView resignFirstResponder];
    }
    
    
    
    
    if([self.nameTextField isFirstResponder]) {
        [self.nameTextField resignFirstResponder];
    }
    
    if([self.emailTextField isFirstResponder]) {
        [self.emailTextField resignFirstResponder];
    }
    
    if([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }
}
@end
