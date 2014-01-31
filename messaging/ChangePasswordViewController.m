//
//  ChangePasswordViewController.m
//  Gleepost
//
//  Created by Silouanos on 31/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "AppearanceHelper.h"
#import "WebClient.h"
#import "WebClientHelper.h"

@interface ChangePasswordViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *simpleNavigationBar;

@property (weak, nonatomic) IBOutlet UITextField *oldPassWord;

@property (weak, nonatomic) IBOutlet UITextField *passWord;

@property (weak, nonatomic) IBOutlet UITextField *passWord2;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureNavigationBar];

}

-(void)configureNavigationBar
{
    
}
- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)saveNewPassword:(id)sender
{
    if(![self areDetailsValid])
    {
        [WebClientHelper showStandardErrorWithTitle:@"Complete fields" andContent:@"Please ensure that all the fieds are not empty."];
        
        return;
    }
    
    //Check if the two new passwords are equal.
    
    if([_passWord.text isEqualToString:_passWord2.text])
    {
        [[WebClient sharedInstance] changePasswordWithOld:_oldPassWord.text andNew:_passWord.text callbackBlock:^(BOOL success) {
            
            if(success)
            {
                [WebClientHelper showStandardErrorWithTitle:@"Password changed" andContent:@"Your password has been changed."];
                
                
                [self goBack:sender];
            }
            else
            {
                [WebClientHelper showStandardErrorWithTitle:@"Password incorrect" andContent:@"Please ensure that your password is right and try again."];
            }
            
        }];
    }
    else
    {
        [WebClientHelper showStandardErrorWithTitle:@"New password wrong" andContent:@"Please ensure that both new password fields contain the same password."];
    }
    

}

#pragma mark - Other methods

-(BOOL)areDetailsValid
{
    return (![self.passWord.text isEqualToString:@""] && ![self.passWord2.text isEqualToString:@""] && ![self.oldPassWord.text isEqualToString:@""]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
