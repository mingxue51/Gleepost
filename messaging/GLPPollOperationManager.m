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
#import "GLPiOSSupportHelper.h"
#import "GLPVoteOperation.h"

@interface GLPPollOperationManager () <GLPVoteOperationDelegate>

/** Will hold all the user's pending votes. <post_remote_key, option> */
@property (strong, nonatomic) NSMutableDictionary *pendingVotes;

@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

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

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.pendingVotes = [[NSMutableDictionary alloc] init];
        self.operationQueue = [[NSOperationQueue alloc] init];
        
        if(![GLPiOSSupportHelper isIOS7])
        {
            self.operationQueue.qualityOfService =  NSQualityOfServiceUtility;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:GLPNOTIFICATION_NETWORK_UPDATE object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_NETWORK_UPDATE object:nil];
}

#pragma mark - NSNotification

- (void)updateNetworkStatus:(NSNotification *)notification
{
    BOOL isNetwork = [notification.userInfo[@"status"] boolValue];
    
    DDLogDebug(@"GLPPollOperationManager updateNetworkStatus pending votes %@", self.pendingVotes);
    
    if(isNetwork)
    {
        for(NSNumber *postRemoteKey in self.pendingVotes)
        {
            NSInteger pollOption = [[self.pendingVotes objectForKey:postRemoteKey] integerValue];
            [self voteWithPollRemoteKey:[postRemoteKey integerValue] andOption:pollOption];
        }
    }
}

#pragma mark - Client

- (void)voteWithPollRemoteKey:(NSInteger)pollRemoteKey andOption:(NSInteger)option
{
    [self.pendingVotes setObject:@(option) forKey:@(pollRemoteKey)];
    
    GLPVoteOperation *voteOperation = [[GLPVoteOperation alloc] initWithPostRemoteKey:pollRemoteKey withUsersOption:option];
    voteOperation.delegate = self;
    [self.operationQueue addOperation:voteOperation];
}

#pragma mark - GLPVoteOpearationDelegate

- (void)voteFailedWithPostRemoteKey:(NSInteger)postRemoteKey
{
    
    DDLogDebug(@"Vote failed with post remote key %ld", (long)postRemoteKey);
}

- (void)voteSuccessfulWithPostRemoteKey:(NSInteger)postRemoteKey
{
    [self.pendingVotes removeObjectForKey:@(postRemoteKey)];
    DDLogInfo(@"Vote successful with post remote key %ld", (long)postRemoteKey);
}

#pragma mark - Web socket

- (void)updatePollPostWithRemoteKey:(NSInteger)postRemoteKey withData:(GLPPoll *)pollData
{
    [self pollUpdatedWithPollRemoteKey:postRemoteKey withNewPollData:pollData];
    [GLPPollDao updatePoll:pollData withPostRemoteKey:postRemoteKey];
}

#pragma mark - Database operations

- (void)updatePollLocallyWithNewData:(GLPPoll *)pollData withPostRemoteKey:(NSInteger)postRemoteKey
{
    [GLPPollDao updatePoll:pollData withPostRemoteKey:postRemoteKey];
}

#pragma mark - Post NSNotification

- (void)failedToVoteWithPollRemoteKey:(NSInteger)pollRemoteKey withOptionSelected:(NSInteger)option
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_POLL_VIEW_STATUS_CHANGED object:self userInfo:@{@"poll_remote_key": @(pollRemoteKey), @"kind_of_operation" : @(kFailedToVote), @"option" : @(option)}];
}

- (void)pollUpdatedWithPollRemoteKey:(NSInteger)pollRemoteKey withNewPollData:(GLPPoll *)pollData
{
    DDLogDebug(@"GLPPollOperationManager updatePoll notification %@ remote key %ld", pollData, pollRemoteKey);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_POLL_VIEW_STATUS_CHANGED object:self userInfo:@{@"poll_remote_key": @(pollRemoteKey), @"kind_of_operation" : @(kPollUpdated), @"poll_updated_data" : pollData}];
}

@end
