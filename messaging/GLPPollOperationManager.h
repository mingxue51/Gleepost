//
//  GLPPollOperationManager.h
//  Gleepost
//
//  Created by Silouanos on 21/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPoll;

typedef NS_ENUM(NSUInteger, PollOperationStatus) {
    kFailedToVote,
    kPollUpdated
};

@interface GLPPollOperationManager : NSObject

+ (GLPPollOperationManager *)sharedInstance;
- (void)voteWithPollRemoteKey:(NSInteger)pollRemoteKey andOption:(NSInteger)option;
- (void)updatePollPostWithRemoteKey:(NSInteger)postRemoteKey withData:(GLPPoll *)pollData;

@end
