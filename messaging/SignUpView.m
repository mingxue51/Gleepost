//
//  SignUpView.m
//  Gleepost
//
//  Created by Silouanos on 26/03/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "SignUpView.h"

@interface SignUpView () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;

@end

@implementation SignUpView


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.firstNameTextField setDelegate:self];
    [self.lastNameTextField setDelegate:self];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag == 1)
    {
        [self becomePasswordFieldFirstResponder];
    }
    else if(textField.tag == 2)
    {
        [self signUp];
    }
    else if (textField.tag == 3)
    {
        [self becomeLastNameFirstResponder];
    }
    else if(textField.tag == 4)
    {
        [self becomeEmailFieldFirstResponder];
    }
    
    return NO;
}

#pragma mark - Navigators

- (void)signUp
{
    if (![self isEmalValid])
    {
        [self.delegate loginSignUpError:kEmailInvalid];
    }
    else if([self areTextFieldsEmpty])
    {
        [self.delegate loginSignUpError:kTextFieldsEmpty];
    }
    else
    {
        [self.delegate signUp];
    }
}

#pragma mark - Accessors

- (NSString *)firstNameTextFieldText
{
    return self.firstNameTextField.text;
}

- (NSString *)lastNameTextFieldText
{
    return self.lastNameTextField.text;
}

#pragma mark - Actions

- (void)becomeFirstNameFirstResponder
{
    [self.firstNameTextField becomeFirstResponder];
}

- (void)becomeLastNameFirstResponder
{
    [self.lastNameTextField becomeFirstResponder];
}

- (void)resignFieldResponder
{
    [super resignFieldResponder];
    
    if([self.firstNameTextField isFirstResponder])
    {
        [self.firstNameTextField resignFirstResponder];
    }
    
    if([self.lastNameTextField isFirstResponder])
    {
        [self.lastNameTextField resignFirstResponder];
    }
}

#pragma mark - Check

- (BOOL)areTextFieldsEmpty
{
    BOOL emailPassEmpty = [super areTextFieldsEmpty];
    
    if(emailPassEmpty)
    {
        return YES;
    }
    
    return ([self.firstNameTextField.text isEqualToString:@""] || [self.lastNameTextField.text isEqualToString:@""]);
}

@end
