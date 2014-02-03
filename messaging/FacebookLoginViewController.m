//
//  FacebookLoginViewController.m
//  Gleepost
//
//  Created by Silouanos on 03/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "FacebookLoginViewController.h"
#import "SignUpWithNameViewController.h"
#import "AppearanceHelper.h"

@interface FacebookLoginViewController ()

@end

@implementation FacebookLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //Set the  colour of navigation bar's title.
    [AppearanceHelper setFormatForLoginNavigationBar:self];
    
    [self setBackground];
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
- (IBAction)skipFacebookLogin:(id)sender
{
    [self performSegueWithIdentifier:@"login name" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SignUpWithNameViewController *signUpForm = segue.destinationViewController;
    
    //finalRegistrationForm.eMailPass = [[NSArray alloc] initWithObjects:self.emailTextView.text, self.passwordTextView.text, nil];
    
    signUpForm.eMailPass = self.eMailPass;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
