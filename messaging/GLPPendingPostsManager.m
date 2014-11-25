//
//  GLPPendingPostsManager.m
//  Gleepost
//
//  Created by Silouanos on 24/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPPendingPostsManager.h"
#import "GLPPost.h"
#import "GLPPostDao.h"
#import "GLPReviewHistoryDao.h"

@interface GLPPendingPostsManager ()

@property (strong, nonatomic) NSMutableArray *pendingPosts;

@end

@implementation GLPPendingPostsManager

static GLPPendingPostsManager *instance = nil;

+ (GLPPendingPostsManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[GLPPendingPostsManager alloc] init];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
        self.pendingPosts = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - Accessors / Modifiers

- (NSInteger)numberOfPendingPosts
{
    return self.pendingPosts.count;
}

/**
 This method adds a new post in the database and in the array.
 
 */
- (void)addNewPendingPost:(GLPPost *)pendingPost
{
    NSAssert([pendingPost isPending], @"Pending post's variable should be true");
    
    [self.pendingPosts addObject:pendingPost];
    
    [GLPPostDao updatePendingStatuswithPost:pendingPost];
}

- (void)updatePendingPost:(GLPPost *)pendingPost
{
    NSAssert([pendingPost isPending], @"Pending post's variable should be true");
    
    [GLPPostDao updatePendingStatuswithPost:pendingPost];
    
    //Add new history record.
    [GLPReviewHistoryDao saveReviewHistory:[pendingPost.reviewHistory lastObject] withPost:pendingPost];
}

- (void)removePendingPost:(GLPPost *)pendingPost
{
    [self removePost:pendingPost];

    [GLPPostDao updatePendingStatuswithPost:pendingPost];
    
    //TODO: Remove history.
    
}

#pragma mark - Helpers

- (void)removePost:(GLPPost *)pendingPost
{
    NSUInteger index = 0;
    
    for(GLPPost *post in self.pendingPosts)
    {
        if(post.remoteKey == pendingPost.remoteKey)
        {
            break;
        }
        ++index;
    }
    
    [self.pendingPosts removeObjectAtIndex:index];
}

@end
