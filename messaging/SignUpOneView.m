//
//  SignUpOneView.m
//  Gleepost
//
//  Created by Silouanos on 05/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "SignUpOneView.h"
#import "ValidFields.h"
#import "WebClientHelper.h"

@implementation SignUpOneView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    [self becomeEmailFieldFirstResponder];
}

- (IBAction)nextView:(id)sender
{
    
    //Check if e-mail and password are valid.
    if([self areDetailsValid])
    {
//        [[super getDelegate] emailAndPass:[super firstAndSecondFields]];
        
        [super nextView];

    }
    else
    {
//        [WebClientHelper showStandardErrorWithTitle:@"Please Check your details" andContent:@"Please check your e-mail or your password."];
    }
    
    //TODO: Check if e-mail is a valid university e-mail.
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
//    [self setUpTextFields];
    
    
    // Drawing code
}

#pragma mark - Other methods

-(BOOL)areDetailsValid
{
    return ([ValidFields NSStringIsValidEmail:[super emailTextFieldText]] && ![[super passwordTextFieldText] isEqualToString:@""]);
}


@end
