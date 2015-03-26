//
//  LoginView.m
//  Gleepost
//
//  Created by Silouanos on 25/03/2015.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "LoginView.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "GLPLoginManager.h"

@interface LoginView () <UITextFieldDelegate>


@end

@implementation LoginView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
    }
    return self;
}


-(void)awakeFromNib
{
    [super awakeFromNib];
    
    
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
        [self login];
    }
    
    return NO;
}

#pragma mark - Navigators

- (void)login
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
        [self.delegate login];
    }
}

- (IBAction)forgotPassword:(id)sender
{
    DDLogDebug(@"LoginView forgot password.");
}


- (IBAction)logIn:(id)sender
{


    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

}

@end
