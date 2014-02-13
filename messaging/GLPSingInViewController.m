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
@property (weak, nonatomic) IBOutlet UILabel *forgotPasswordMsgLbl;


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
    
    //Check e-mail.
    
//    if(![super isEmalValid])
//    {
//        [WebClientHelper showStandardEmailError];
//        
//        return;
//    }
    
    //Check password.
    
//    if(![super isPasswordValid])
//    {
//        [WebClientHelper showStandardPasswordError];
//        
//        return;
//        
//    }
    
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
//                [WebClientHelper showStandardErrorWithTitle:@"Password reseted" andContent:@"Please check your email and complete the resetting procedure"];
                
                [_forgotPasswordMsgLbl setText:[NSString stringWithFormat:@"No problem. We've just sent you a password recovery link at: %@",self.email]];
            }
            else
            {
                [WebClientHelper showStandardError];
            }
            
        }];
    }
    else
    {
        [WebClientHelper showStandardEmailError];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
