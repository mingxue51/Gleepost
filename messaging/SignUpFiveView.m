//
//  SignUpFiveView.m
//  Gleepost
//
//  Created by Σιλουανός on 6/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "SignUpFiveView.h"

@implementation SignUpFiveView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)goToMain:(id)sender
{
    //If the user is registered then log in.
    
    DDLogDebug(@"Log in!");
}
- (IBAction)resendVerification:(id)sender {
    
    DDLogDebug(@"Resend verification!");

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
