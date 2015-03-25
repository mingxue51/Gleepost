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

@interface LoginView ()


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
//    [self becomeEmailFieldFirstResponder];
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
