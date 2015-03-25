//
//  RegisterView.m
//  Gleepost
//
//  Created by Silouanos on 05/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "RegisterView.h"

@interface RegisterView ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) UIViewController <RegisterViewsProtocol> *delegate;

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

#pragma mark - Navigators

-(void)login
{
    [_delegate login];
}

-(void)nextView
{
    [_delegate navigateToNextView];
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

//TODO: Apply the next approach. So when data are valid let the user to continue.

//-(BOOL)areTheDetailsValid
//{
//    return (![self.first.text isEqualToString:@""] && ![self.second.text isEqualToString:@""]);
//}

-(UIViewController<RegisterViewsProtocol> *)getDelegate
{
    return _delegate;
}

#pragma mark - Modifiers

-(void)becomeEmailFieldFirstResponder
{
    [self.emailTextField becomeFirstResponder];
}

-(void)resignFieldResponder
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


-(void)setDelegate:(UIViewController<RegisterViewsProtocol> *)delegate
{
    _delegate = delegate;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code

}


@end
