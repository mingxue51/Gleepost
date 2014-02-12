//
//  GLPSingInViewController.m
//  Gleepost
//
//  Created by Σιλουανός on 6/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPSingInViewController.h"
#import "WebClientHelper.h"
#import "GLPLoginManager.h"
#import "WebClient.h"

@interface GLPSingInViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *simpleNavBar;


@end

@implementation GLPSingInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [super setDefaultTextToEmailAndPassFields];
    
}

#pragma mark - Selectors

- (IBAction)login:(id)sender
{
    [super loginUserFromLoginScreenWithImage:nil];
}

//TODO: Call this method.

-(void)configureNavigationBar
{
//    [self.simpleNavBar setBackgroundColor:[UIColor clearColor]];
    
    [self.simpleNavBar setTranslucent:NO];
    [self.simpleNavBar setFrame:CGRectMake(0.f, 0.f, 320.f, 100.f)];
    self.simpleNavBar.tintColor = [UIColor whiteColor];
    
    [self.simpleNavBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor,[UIFont fontWithName:GLP_APP_FONT size:20.0f], UITextAttributeFont, nil]];
}

- (IBAction)forgotPassword:(id)sender
{
    if([self isEmalValid])
    {
        //Communicate with server to send verification to email.
        [[WebClient sharedInstance] resetPasswordWithEmail:[self email] callbackBlock:^(BOOL success) {
            
            if(success)
            {
                [WebClientHelper showStandardErrorWithTitle:@"Password reseted" andContent:@"Please check your email and complete the resetting procedure"];
            }
            else
            {
                [WebClientHelper showStandardErrorWithTitle:@"Problem resetting your password" andContent:@"Please check your email and try again"];
            }
            
        }];
    }
    else
    {
        [WebClientHelper showStandardErrorWithTitle:@"Email not valid" andContent:@"Please make sure that your email is valid and try again"];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
