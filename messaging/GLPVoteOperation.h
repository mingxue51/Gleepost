//
//  GLPVoteOperation.h
//  Gleepost
//
//  Created by Silouanos on 18/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GLPVoteOperationDelegate <NSObject>

- (void)voteFailedWithPostRemoteKey:(NSInteger)postRemoteKey;
- (void)voteSuccessfulWithPostRemoteKey:(NSInteger)postRemoteKey;

@end

@interface GLPVoteOperation : NSOperation

- (id)initWithPostRemoteKey:(NSInteger)remoteKey withUsersOption:(NSInteger)usersOption;

@property (weak, nonatomic) id<GLPVoteOperationDelegate> delegate;

@end
