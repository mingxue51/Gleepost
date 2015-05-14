//
//  GLPCLCommentsOperation.m
//  Gleepost
//
//  Created by Silouanos on 11/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPCLCommentsOperation.h"
#import "GLPPost.h"
#import "GLPCommentManager.h"

@interface GLPCLCommentsOperation ()

@property (strong, nonatomic) GLPPost *post;

@end

@implementation GLPCLCommentsOperation

- (id)initWithPost:(GLPPost *)post
{
    self = [super init];
    
    if(self)
    {
        self.post = post;
    }
    
    return self;
}

- (void)main {
    @autoreleasepool {
        DDLogInfo(@"GLPCelCommentsOperation operation started %@", self.post);
        [self startLoadingComments];
    }
}

- (void)startLoadingComments
{
    [GLPCommentManager loadCommentsWithPost:self.post localCallback:^(NSArray *localComments) {
        
        NSArray *reversedComments = [[localComments reverseObjectEnumerator] allObjects];
        [self.delegate comments:reversedComments forPost:self.post];
        
    } remoteCallback:^(BOOL success, NSArray *remoteComments){
        
        if(success)
        {
            NSArray *reversedComments = [[remoteComments reverseObjectEnumerator] allObjects];
            [self.delegate comments:reversedComments forPost:self.post];
        }
        
    }];
}

@end
