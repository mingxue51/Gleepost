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
    
    [self.pendingPosts insertObject:pendingPost atIndex:0];
    
    [GLPPostDao updatePendingStatuswithPost:pendingPost];
}

- (void)updatePendingPostAfterEdit:(GLPPost *)pendingPost
{
//    NSAssert([pendingPost isPending], @"Pending post's variable should be true");
    
//    [self updatePendingPostInMemory:pendingPost];
    
    [GLPPostDao saveOrUpdatePost:pendingPost];
    
    DDLogDebug(@"GLPPendingPostsManager : New review history %@", [pendingPost.reviewHistory lastObject]);
    
    //Add new history record.
    [GLPReviewHistoryDao saveReviewHistory:[pendingPost.reviewHistory lastObject] withPost:pendingPost];
}

- (void)updatePendingPostBeforeEdit:(GLPPost *)pendingPost
{    
    [GLPPostManager updatePostBeforeEditing:pendingPost];
    
    DDLogDebug(@"updatePendingPostBeforeEdit %@", pendingPost);
}

- (void)removePendingPost:(GLPPost *)pendingPost
{
    [self removePost:pendingPost];

    [GLPPostDao updatePendingStatuswithPost:pendingPost];
    
    //Remove history.
    [GLPReviewHistoryDao removeReviewHistoryWithPost:pendingPost];
    
}

- (GLPPost *)postWithRemoteKey:(NSInteger)postRemoteKey
{
    for(GLPPost *p in self.pendingPosts)
    {
        if(p.remoteKey == postRemoteKey)
        {
            return p;
        }
    }
    return nil;
}


#pragma mark - Client

/**
 Load all user's pending posts and save them to local database.
 */

- (void)loadPendingPosts
{
    self.pendingPosts = [GLPPostDao loadPendingPosts].mutableCopy;

    [[WebClient sharedInstance] getPostsWaitingForApprovalCallbackBlock:^(BOOL success, NSArray *pendingPosts) {
       
        if(success)
        {
            self.pendingPosts = pendingPosts.mutableCopy;
            
            //Update local database if there is a need.
            [self updateLocalDatabase];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_NEW_PENDING_POST object:nil];
        }
        
    }];
}

- (void)loadPendingPostsWithLocalCallback:(void (^) (NSArray *localPosts))localCallback withRemoteCallback:(void (^) (BOOL success, NSArray *remotePosts))remoteCallback
{
    if(self.pendingPosts.count == 0)
    {
        self.pendingPosts = [GLPPostDao loadPendingPosts].mutableCopy;
    }
    
    localCallback(self.pendingPosts);
    
    [[WebClient sharedInstance] getPostsWaitingForApprovalCallbackBlock:^(BOOL success, NSArray *pendingPosts) {
        
        if(success)
        {
            
//            self.pendingPosts = pendingPosts.mutableCopy;
            
            //Update local database if there is a need.
            [self updateLocalDatabase];
            
            [self addAnySendingPendingPostsWithRemotePendingPosts:pendingPosts.mutableCopy];
            
            remoteCallback(YES, self.pendingPosts.mutableCopy);
                        
            [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_NEW_PENDING_POST object:nil];

        }
        else
        {
            remoteCallback(NO, nil);
        }
        
    }];
}

- (void)clean
{
    [self.pendingPosts removeAllObjects];
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
        
        DDLogDebug(@"GLPPendingPostsManager : pending post key %ld", (long)pendingPost.key);
        
        //Review history.
        [GLPReviewHistoryDao saveReviewHistoryArrayOfPost:pendingPost];
    }
}

#pragma mark - Helpers

- (void)removePost:(GLPPost *)pendingPost
{
    NSInteger postIndex = [self findPostIndexWithPost:pendingPost];
    [self.pendingPosts removeObjectAtIndex:postIndex];
}

//For now don't use this method. It's useless because we are doing the update in
//local database.

//- (void)updatePendingPostInMemory:(GLPPost *)pendingPost
//{
//    NSInteger postIndex = [self findPostIndexWithPost:pendingPost];
//    
//    DDLogInfo(@"GLPPendingPostsManager replace post with remote key %ld current post remote key %ld", (long)pendingPost.remoteKey, (long)[(GLPPost *)[self.pendingPosts objectAtIndex:postIndex] remoteKey]);
//    
//    [self.pendingPosts replaceObjectAtIndex:postIndex withObject:pendingPost];
//}

- (NSInteger)findPostIndexWithPost:(GLPPost *)pendingPost
{
    NSUInteger index = 0;
    
    for(GLPPost *post in self.pendingPosts)
    {
        DDLogDebug(@"findPostIndexWithPost post %@", post);
        
        if(post.remoteKey == pendingPost.remoteKey)
        {
            break;
        }
        ++index;
    }
    return index;
}

- (void)addAnySendingPendingPostsWithRemotePendingPosts:(NSMutableArray *)remotePendingPosts
{
    NSMutableArray *oldPendingPosts = [[NSMutableArray alloc] init];
    
    //Find the posts with send status local.
    
    for(GLPPost *p in self.pendingPosts)
    {
        if(p.sendStatus == kSendStatusLocal)
        {
            DDLogDebug(@"Pending post %@", p.content);
            [oldPendingPosts addObject:p];
        }
    }
    
    for(GLPPost *p in oldPendingPosts)
    {
        [remotePendingPosts setObject:p atIndexedSubscript:0];
    }
    
    
    self.pendingPosts = remotePendingPosts;
    
}

@end
