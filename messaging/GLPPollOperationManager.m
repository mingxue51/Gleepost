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
#import "GLPPollDao.h"

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

#pragma mark - Web socket

- (void)updatePollPostWithRemoteKey:(NSInteger)postRemoteKey withData:(GLPPoll *)pollData
{
    [self pollUpdatedWithPollRemoteKey:postRemoteKey withNewPollData:pollData];
    [GLPPollDao updatePoll:pollData withPostRemoteKey:postRemoteKey];
}


#pragma mark - Post NSNotification

- (void)failedToVoteWithPollRemoteKey:(NSInteger)pollRemoteKey withOptionSelected:(NSInteger)option
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_POLL_VIEW_STATUS_CHANGED object:self userInfo:@{@"poll_remote_key": @(pollRemoteKey), @"kind_of_operation" : @(kFailedToVote), @"option" : @(option)}];
}

- (void)pollUpdatedWithPollRemoteKey:(NSInteger)pollRemoteKey withNewPollData:(GLPPoll *)pollData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_POLL_VIEW_STATUS_CHANGED object:self userInfo:@{@"poll_remote_key": @(pollRemoteKey), @"kind_of_operation" : @(kPollUpdated), @"poll_updated_data" : pollData}];
}

@end
