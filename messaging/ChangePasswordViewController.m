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
#import "GLPUserDao.h"

@interface ChangePasswordViewController ()


@property (weak, nonatomic) IBOutlet UITextField *oldPassWord;

@property (weak, nonatomic) IBOutlet UITextField *passWord;

@property (weak, nonatomic) IBOutlet UITextField *passWord2;

@property (weak, nonatomic) IBOutlet UIImageView *separatorLastTextField;
 
@property (weak, nonatomic) IBOutlet UIButton *changeButton;

@end

@implementation ChangePasswordViewController

@synthesize isPasswordChange = _isPasswordChange;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureView];
    [self showKeyboardOnTheFirstTextField];
}

-(void)configureNavigationBar
{
    if(_isPasswordChange)
    {
        self.title = @"CHANGE PASSWORD";
    }
    else
    {
        self.title = @"CHANGE NAME";
    }
    
    
//    [AppearanceHelper setNavigationBarFontForNavigationBar:_simpleNavigationBar];
}

-(void)configureView
{
    if(!_isPasswordChange)
    {
        //Remove the first field and change their text placeholders.
        [_passWord2 setHidden:YES];
        [_separatorLastTextField setHidden:YES];
        [_oldPassWord setPlaceholder:@"New name"];
        [_passWord setPlaceholder:@"New surname"];
        [_oldPassWord setSecureTextEntry:NO];
        [_passWord setSecureTextEntry:NO];
        [_changeButton setTitle:@"CHANGE NAME" forState:UIControlStateNormal];
    }
}

- (IBAction)saveNewPassword:(id)sender
{

    if(_isPasswordChange)
    {
        [self changePassword];
    }
    else
    {
        [self changeName];
    }
}

- (void)changePassword
{
    if(![self areDetailsValid])
    {
        [WebClientHelper showStandardErrorWithTitle:@"Complete fields" andContent:@"Please ensure that all the fields are completed."];
        
        return;
    }
    
    //Check if the two new passwords are equal.
    
    if([_passWord.text isEqualToString:_passWord2.text])
    {
        [self hideKeyboard];
        
        [WebClientHelper showStandardLoaderWithTitle:@"Changing password..." forView:self.view];
        
        [[WebClient sharedInstance] changePasswordWithOld:_oldPassWord.text andNew:_passWord.text callbackBlock:^(BOOL success) {
            
            [WebClientHelper hideStandardLoaderForView:self.view];
            
            if(success)
            {
                [WebClientHelper showStandardErrorWithTitle:@"Password changed" andContent:@"Your password has been changed"];
                
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [self showAlertViewWithTitle:@"Password incorrect" andContent:@"Please ensure that your password is right and try again"];
                
            }
            
        }];
    }
    else
    {
        [self showAlertViewWithTitle:@"New password wrong" andContent:@"Please ensure that both new password fields contain the same password."];
    }
}

- (void)changeName
{
    //Change name.
    if(![self areNameDetailsValid])
    {
        [WebClientHelper showStandardErrorWithTitle:@"Complete fields" andContent:@"Please ensure that all the fieds are not empty."];
        
        return;
    }
    else
    {
        [self hideKeyboard];
        
        [WebClientHelper showStandardLoaderWithTitle:@"Changing name..." forView:self.view];
        
        [[WebClient sharedInstance] changeNameWithName:_oldPassWord.text andSurname:_passWord.text callbackBlock:^(BOOL success) {
            
            [WebClientHelper hideStandardLoaderForView:self.view];
            
            if(success)
            {
                [WebClientHelper showStandardErrorWithTitle:@"Name changed" andContent:[NSString stringWithFormat:@"Your new name is: %@ %@.",_oldPassWord.text, _passWord.text]];
                
                //Update database with the new name.
                [GLPUserDao updateLoggedInUsersName:_oldPassWord.text andSurname:_passWord.text];
                
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                //                    [WebClientHelper showStandardErrorWithTitle:@"Failed to change name" andContent:@"Please make sure that you are connected with internet and try again."];
                
                [self showAlertViewWithTitle:@"Failed to change name" andContent:@"Please make sure that you are connected with internet and try again."];
                
            }
            
        }];
    }
}

#pragma mark - AlertView

- (void)showAlertViewWithTitle:(NSString *)title andContent:(NSString *)content
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:content
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self showKeyboardOnTheFirstTextField];
}


#pragma mark - Keyboard management

- (void)hideKeyboard
{
    [self.view endEditing:YES];
}

- (void)showKeyboardOnTheFirstTextField
{
    [self.oldPassWord becomeFirstResponder];
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
