//
//  GLPViewControllerHelper.m
//  Gleepost
//
//  Created by Lukas on 2/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPViewControllerHelper.h"

@interface GLPViewControllerHelper()

@property (strong, nonatomic) UIAlertView *networkErrorAlertView;

@end


@implementation GLPViewControllerHelper

@synthesize networkErrorAlertView=_networkErrorAlertView;

static GLPViewControllerHelper *instance = nil;

+ (GLPViewControllerHelper *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPViewControllerHelper alloc] init];
    });
    
    return instance;
}

- (void)showErrorNetworkMessage
{
    if(_networkErrorAlertView) {
        return;
    }
    
    _networkErrorAlertView = [[UIAlertView alloc] initWithTitle:@"No network" message:@"You are not connected to the chat, check your network" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [_networkErrorAlertView show];
}

- (void)hideErrorNetworkMessage
{
    if(_networkErrorAlertView) {
        [_networkErrorAlertView dismissWithClickedButtonIndex:0 animated:YES];
        _networkErrorAlertView = nil;
    }
}


@end
