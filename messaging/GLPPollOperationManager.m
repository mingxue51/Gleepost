//
//  GLPPollOperationManager.m
//  Gleepost
//
//  Created by Silouanos on 21/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Manages all operations have to do with polling.

#import "GLPPollOperationManager.h"
#import "WebClient.h"

static GLPPollOperationManager *instance = nil;

@implementation GLPPollOperationManager

+ (GLPPollOperationManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[GLPPollOperationManager alloc] init];
    });
    
    return instance;
}

#pragma mark - Client

- (void)voteWithPollRemoteKey:(NSInteger)pollRemoteKey andOption:(NSInteger)option
{
    [[WebClient sharedInstance] voteWithPostRemoteKey:pollRemoteKey andOption:option callbackBlock:^(BOOL success, NSString *statusMsg) {
       
        //Revert only when there is only a network connection issue.
        
        if(!success && [statusMsg isEqualToString:@"network issue"])
        {
            [self failedToVoteWithPollRemoteKey:pollRemoteKey withOptionSelected:option];
        }
        
    }];
}

#pragma mark - Post NSNotification

- (void)failedToVoteWithPollRemoteKey:(NSInteger)pollRemoteKey withOptionSelected:(NSInteger)option
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_POLL_VIEW_STATUS_CHANGED object:self userInfo:@{@"poll_remote_key": @(pollRemoteKey), @"kind_of_operation" : @(kFailedToVote), @"option" : @(option)}];
}

@end
