//
//  WalkThroughHelper.m
//  Gleepost
//
//  Created by Silouanos on 12/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "WalkThroughHelper.h"
#import "SessionManager.h"

@implementation WalkThroughHelper

+(void)showCampusWallMessage
{
    if([[SessionManager sharedInstance] isFirstTimeLoggedIn])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome to your Campus Feed"
                                                        message:@"Use it find out about cool events, news and much more going on on campus"
                                                       delegate:nil
                                              cancelButtonTitle:@"got it!"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

+(BOOL)isReadyToShowRandomChat
{
    if([[SessionManager sharedInstance] isFirstTimeLoggedIn])
    {
        [[SessionManager sharedInstance] firstTimeLoggedInActivate];
        
        return NO;
    }
    else
    {
        return YES;
    }
    
}

+(void)showRandomChatMessageWithDelegate:(ChatViewAnimationController *)delegate
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Random chatting"
                                                    message:@"We'll pair you into a chat with a random peer on campus. All conversations expire after 24 hours, and you can have up to 3 concurrently. Happy chatting!"
                                                   delegate:delegate
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Continue", nil];
    [alert show];
    
    
}

@end
