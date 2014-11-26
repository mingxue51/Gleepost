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
#import "GLPPostManager.h"
#import "GLPReviewHistoryDao.h"
#import "WebClient.h"

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
        [self loadPendingPosts];
    }
    
    return self;
}

#pragma mark - Accessors / Modifiers

- (NSInteger)numberOfPendingPosts
{
    return self.pendingPosts.count;
}

- (BOOL)arePendingPosts
{
    return (self.pendingPosts.count != 0);
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
    
    //Remove history.
    [GLPReviewHistoryDao removeReviewHistoryWithPost:pendingPost];
    
}

#pragma mark - Client

/**
 Load all user's pending posts and save them to local database.
 */

- (void)loadPendingPosts
{
    [[WebClient sharedInstance] getPostsWaitingForApprovalCallbackBlock:^(BOOL success, NSArray *pendingPosts) {
       
        if(success)
        {
            self.pendingPosts = pendingPosts.mutableCopy;
            
            //Update local database if there is a need.
            [self updateLocalDatabase];
            DDLogDebug(@"Pending posts from server %@", pendingPosts);
        }
        
    }];
}

#pragma mark - Database

/**
 Checks if there is any new information in the new fetched posts and updates the database.
 (Update pending post or create new ones). <br>
 Actions <br>
 - Removes all the data from review history and adds it again. <br>
 - Checks if there is a new pending post (not possible except the user comes from a new log in) 
 or post that is approved and change the status as appropriate. <br>
 
 Use cases <br>
 - A post is approved (so it will not be in the response). <br>
 - There is an updated history on the post. (like a post is rejected etc.) <br>
 - Post is edited (?)
 */
- (void)updateLocalDatabase
{
    [GLPReviewHistoryDao deleteReviewHistoryTable];
    
    for(GLPPost *pendingPost in self.pendingPosts)
    {
        
        //Post.
        [GLPPostDao saveOrUpdatePost:pendingPost];
        
        //Review history.
        [GLPReviewHistoryDao saveReviewHistoryArrayOfPost:pendingPost];
    }
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
