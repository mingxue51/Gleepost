//
//  LoginView.m
//  Gleepost
//
//  Created by Silouanos on 05/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "LoginView.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "GLPLoginManager.h"

@interface LoginView ()

//@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
//@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;


@end

@implementation LoginView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        // Initialization code
//        [self setUpTextFields];

    }
    return self;
}


-(void)awakeFromNib
{
    [self becomeFirstFieldFirstResponder];
    
    if(DEV)
    {
        if(!ON_DEVICE)
        {
            
            [self setTextToFirst:@"fingolfin@leeds.ac.uk" andToSecond:@"ihatemorgoth"];

            
        } else
        {
            [self setTextToFirst:@"sc11pm@leeds.ac.uk" andToSecond:@"TestingPass"];

        }
    }

}

- (IBAction)forgotPassword:(id)sender
{

}


- (IBAction)logIn:(id)sender
{
    [WebClientHelper showStandardLoaderWithTitle:@"Login" forView:self];
    
    [GLPLoginManager loginWithIdentifier:[self textFirstTextField] andPassword:[self textSecondTextField] callback:^(BOOL success) {
        
        [WebClientHelper hideStandardLoaderForView:self];
        
        if(success) {
            [self login];
            
        } else {

            [WebClientHelper showStandardErrorWithTitle:@"Login failed" andContent:@"Check your credentials or your internet connection, dude."];



        }
    }];

    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self setUpTextFields];

    
    // Drawing code
    

}


@end
