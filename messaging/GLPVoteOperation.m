//
//  GLPVoteOperation.m
//  Gleepost
//
//  Created by Silouanos on 18/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPVoteOperation.h"
#import "WebClient.h"

@interface GLPVoteOperation ()

@property (assign, nonatomic) NSInteger postRemoteKey;
@property (assign, nonatomic) NSInteger usersOption;

@end

@implementation GLPVoteOperation

- (id)initWithPostRemoteKey:(NSInteger)remoteKey withUsersOption:(NSInteger)usersOption
{
    self = [super init];
    
    if(self)
    {
        self.postRemoteKey = remoteKey;
        self.usersOption = usersOption;
    }
    
    return self;
}


- (void)main {
    
    @autoreleasepool {
        
        DDLogInfo(@"GLPVoteOperation started %ld : %ld", (long)self.usersOption, (long)self.postRemoteKey);
        
        [self executeTask];
    }
}

- (void)executeTask
{
    [[WebClient sharedInstance] voteWithPostRemoteKey:self.postRemoteKey andOption:self.usersOption callbackBlock:^(BOOL success, NSString *statusMsg) {
        
        //Revert only when there is only a network connection issue.
        
        if(!success && [statusMsg isEqualToString:@"network issue"])
        {
            
            [self.delegate voteFailedWithPostRemoteKey:self.postRemoteKey];
            
//            [self failedToVoteWithPollRemoteKey:pollRemoteKey withOptionSelected:option];
        }
        else
        {
            //TODO: Update the database.
            
            [self.delegate voteSuccessfulWithPostRemoteKey:self.postRemoteKey];
        }
        
    }];
}

@end
