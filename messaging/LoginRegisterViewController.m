//
//  LoginRegisterViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 16/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "LoginRegisterViewController.h"
#import "AppearanceHelper.h"


@interface LoginRegisterViewController ()


@end

@implementation LoginRegisterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    //Change the colour format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [AppearanceHelper setNavigationBarBackgroundImageFor:self imageName:@"navigationbar_trans" forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    
    
    [self setBackground];
    
    [self setImages];
}

- (IBAction)gleepostSignUp:(id)sender
{
    [self performSegueWithIdentifier:@"register" sender:self];
}


- (IBAction)signIn:(id)sender
{
    [self performSegueWithIdentifier:@"login" sender:self];
}

-(void)setImages
{
    
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

@end
