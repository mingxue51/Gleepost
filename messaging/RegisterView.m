//
//  RegisterView.m
//  Gleepost
//
//  Created by Silouanos on 05/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "RegisterView.h"
#import "ValidFields.h"

@interface RegisterView () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation RegisterView

-(id)initWithCoder:(NSCoder *)aDecoder withFirstTextField:(UITextField *)first andSecond:(UITextField *)second
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.emailTextField setDelegate:self];
    [self.passwordTextField setDelegate:self];
}

#pragma mark - Accessors

-(NSString *)emailTextFieldText
{
    return self.emailTextField.text;
}


-(NSString *)passwordTextFieldText
{
    return self.passwordTextField.text;
}

#pragma mark - Modifiers

-(void)becomeEmailFieldFirstResponder
{
    [self.emailTextField becomeFirstResponder];
}

- (void)becomePasswordFieldFirstResponder
{
    [self.passwordTextField becomeFirstResponder];
}

- (void)resignFieldResponder
{
    if([self.emailTextField isFirstResponder])
    {
        [self.emailTextField resignFirstResponder];
    }
    
    if([self.passwordTextField isFirstResponder])
    {
        [self.passwordTextField resignFirstResponder];
    }
}

- (void)startLoading
{
    [self disableTextFields];
    [self.activityIndicatorView startAnimating];
}

- (void)stopLoading
{
    [self enableTextFields];
    [self.activityIndicatorView stopAnimating];
}

- (void)disableTextFields
{
    [self.emailTextField setEnabled:NO];
    [self.passwordTextField setEnabled:NO];
}

- (void)enableTextFields
{
    [self.emailTextField setEnabled:YES];
    [self.passwordTextField setEnabled:YES];
}


#pragma mark - Check

- (BOOL)isEmalValid
{
    if ([self.emailTextField.text rangeOfString:@".edu"].location == NSNotFound && [self.emailTextField.text rangeOfString:@"gleepost.com"].location == NSNotFound)
    {
        return NO;
        
    } else
    {
        return [ValidFields NSStringIsValidEmail:self.emailTextField.text];
    }
    
}

//TODO: Apply the next approach. So when data are valid let the user to continue.

- (BOOL)areTextFieldsEmpty
{
    return ([self.emailTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code

}


@end
