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

@property (weak, nonatomic) IBOutlet UINavigationItem *item2;

@end

@implementation ChangePasswordViewController

@synthesize isPasswordChange = _isPasswordChange;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureView];

}

-(void)configureNavigationBar
{
    [AppearanceHelper setNavigationBarFontForNavigationBar:_simpleNavigationBar];
}

-(void)configureView
{
    if(!_isPasswordChange)
    {
        //Remove the first field and change their text placeholders.
        [_passWord2 setHidden:YES];
        [_oldPassWord setPlaceholder:@"New name"];
        [_passWord setPlaceholder:@"New surname"];
        [_oldPassWord setSecureTextEntry:NO];
        [_passWord setSecureTextEntry:NO];
        
        [_item2 setTitle:@"Change Name"];
    }
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveNewPassword:(id)sender
{

    
    if(_isPasswordChange)
    {

        if(![self areDetailsValid])
        {
            [WebClientHelper showStandardErrorWithTitle:@"Complete fields" andContent:@"Please ensure that all the fields are completed."];
            
            return;
        }
        
        //Check if the two new passwords are equal.
        
        if([_passWord.text isEqualToString:_passWord2.text])
        {
            [[WebClient sharedInstance] changePasswordWithOld:_oldPassWord.text andNew:_passWord.text callbackBlock:^(BOOL success) {
                
                if(success)
                {
                    [WebClientHelper showStandardErrorWithTitle:@"Password changed" andContent:@"Your password has been changed"];
                    
                    
                    [self goBack:sender];
                }
                else
                {
                    [WebClientHelper showStandardErrorWithTitle:@"Password incorrect" andContent:@"Please ensure that your password is right and try again"];
                }
                
            }];
        }
        else
        {
            [WebClientHelper showStandardErrorWithTitle:@"New password wrong" andContent:@"Please ensure that both new password fields contain the same password."];
        }
    }
    else
    {
        //Change name.
        if(![self areNameDetailsValid])
        {
            [WebClientHelper showStandardErrorWithTitle:@"Complete fields" andContent:@"Please ensure that all the fieds are not empty."];
            
            return;
        }
        else
        {
            [[WebClient sharedInstance] changeNameWithName:_oldPassWord.text andSurname:_passWord.text callbackBlock:^(BOOL success) {
               
                if(success)
                {
                    [WebClientHelper showStandardErrorWithTitle:@"Name changed" andContent:[NSString stringWithFormat:@"Your new name is: %@ %@.",_oldPassWord.text, _passWord.text]];
                    
                    
                    [self goBack:sender];
                }
                else
                {
                    [WebClientHelper showStandardErrorWithTitle:@"Failed to change name" andContent:@"Please make sure that you are connected with internet and try again."];
                }
                
            }];
        }
    }
    

    

}

#pragma mark - Other methods

-(BOOL)areDetailsValid
{
    return (![self.passWord.text isEqualToString:@""] && ![self.passWord2.text isEqualToString:@""] && ![self.oldPassWord.text isEqualToString:@""]);
}

-(BOOL)areNameDetailsValid
{
    return (![self.passWord.text isEqualToString:@""] && ![self.oldPassWord.text isEqualToString:@""]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
