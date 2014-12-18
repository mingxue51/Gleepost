//
//  SignUpFourView.m
//  Gleepost
//
//  Created by Σιλουανός on 6/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "SignUpFourView.h"
#import "WebClient.h"
#import "LoginRegisterViewController.h"

@interface SignUpFourView ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation SignUpFourView

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
    [self becomeFirstFieldFirstResponder];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectImage:)];
    [tap setNumberOfTapsRequired:1];
    [self.profileImageView addGestureRecognizer:tap];
}


- (IBAction)registerUser:(id)sender
{
    LoginRegisterViewController *d = (LoginRegisterViewController*)[super getDelegate];
    
    
    NSArray *firstLastName = [d firstLastName];
    
    NSArray *emailPass = [d emailPass];
    
    if([self areTheDetailsValid])
    {
        //Request to server to register user.
    
        [WebClientHelper showStandardLoaderWithTitle:@"Registering" forView:self];
        
        [[WebClient sharedInstance] registerWithName:firstLastName[0] surname:firstLastName[1] email:emailPass[0] password:emailPass[1] andCallbackBlock:^(BOOL success, NSString *responseMessage, int remoteKey) {
            
            [WebClientHelper hideStandardLoaderForView:self];
            
            if(success)
            {
                //Navigate to home.
                NSLog(@"User register successful with remote Key: %d", remoteKey);
                [super nextView];
                //[self loginUser];
            }
            else
            {
                NSLog(@"User not registered.");
//                [WebClientHelper showStandardErrorWithTitle:@"Authentication Failed" andContent:responseMessage];
            }
            
        }];
        
        
    }
    else
    {
//        [WebClientHelper showStandardErrorWithTitle:@"Please Check your details" andContent:@"Please check your details if are valid."];
    }
    
}

-(void)selectImage:(id)sender
{
    [[super getDelegate] pickImage:sender];
}

-(void)setImage:(UIImage *)image
{
    [_profileImageView setImage:image];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self setUpTextFields];
    
}

@end
