//
//  GLPLiveGroupManager.m
//  Gleepost
//
//  Created by Σιλουανός on 29/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This manager is a singleton and it works (in co-operation with GLPGroupManager) once the app launced.
//  The aim of this manager is to pre-fetch all the groups before viewing the groups' tab
//  and in genera to handle all the group operations.
//

#import "GLPLiveGroupManager.h"
#import "GLPGroupManager.h"
#import "WebClient.h"
#import "GLPGroupDao.h"

@interface GLPLiveGroupManager ()

@property (strong, nonatomic) dispatch_queue_t queue;

@property (strong, nonatomic) NSMutableArray *groups;

@property (strong, nonatomic) NSMutableDictionary *unreadPostGroups;

@end

static GLPLiveGroupManager *instance = nil;

@implementation GLPLiveGroupManager

+ (GLPLiveGroupManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
       
        instance = [[GLPLiveGroupManager alloc] init];
        
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _groups = [[NSMutableArray alloc] init];
        _queue = dispatch_queue_create("com.gleepost.queue.livegroups", DISPATCH_QUEUE_SERIAL);
        _unreadPostGroups = [[NSMutableDictionary alloc] init];

    }
    
    return self;
}

/**
 This method should be called ONLY when the app is launced.
 
 */
- (void)loadGroups
{
    DDLogInfo(@"Load groups");
    
    [GLPGroupManager loadGroups:_groups withLocalCallback:^(NSArray *groups) {
        
        _groups = groups.mutableCopy;
        
    } remoteCallback:^(BOOL success, NSArray *groups) {
        
        _groups = groups.mutableCopy;
        
    }];
}

- (void)loadGroupsWithPendingGroups:(NSArray *)pending withLiveCallback:(void (^) (NSArray* groups))local remoteCallback:(void (^) (BOOL success, NSArray *remoteGroups))remote
{
    
    //Find all the groups that contain real images and save them.
    NSMutableArray *pendingGroups = [[GLPGroupManager findGroupsWithRealImagesWithGroups:pending] mutableCopy];
    
    DDLogDebug(@"Pending groups: %@", pendingGroups);
    
    
    
    //Add any new images that are uploading in GroupOperationManager.
    _groups = [GLPGroupManager addPendingImagesIfExistWithGroups:_groups.mutableCopy].mutableCopy;
    
    local(_groups);
    
    [[WebClient sharedInstance ] getGroupswithCallbackBlock:^(BOOL success, NSArray *serverGroups) {
        
        if(!success) {
            remote(NO, nil);
            return;
        }
        
        //Store only groups that are not exist into the database.
        
        [GLPGroupDao saveGroups:serverGroups];
        
        _groups = [serverGroups mutableCopy];
        
        [_groups addObjectsFromArray:pendingGroups];

        
        remote(YES, _groups);
    }];
}

#pragma mark - Updates

- (void)addUnreadPostWithGroupRemoteKey:(NSInteger)groupKey
{
    GLPGroup *g = nil;
    
    g = [_unreadPostGroups objectForKey:@(groupKey)];
      
    if(!g)
    {
        g =  [self findGroupWithRemoteKey:groupKey];
    }
    
    if (!g)
    {
        DDLogError(@"Group not found, abort.");
        
        return;
    }
    
    ++g.unreadNewPosts;
    
    [_unreadPostGroups setObject:g forKey:@(groupKey)];
    
    DDLogDebug(@"GROUP ADDED: %@", _unreadPostGroups);

}

- (void)postGroupReadWithRemoteKey:(NSInteger)groupKey
{
    [_unreadPostGroups removeObjectForKey:@(groupKey)];
    
    DDLogDebug(@"GROUP REMOVED: %@", _unreadPostGroups);
}

- (NSInteger)numberOfUnseenPostsWithGroup:(GLPGroup *)group
{
    GLPGroup *g = [_unreadPostGroups objectForKey:@(group.remoteKey)];
    
    if(g)
    {
        return g.unreadNewPosts;
    }
    
    return 0;
}

- (GLPGroup *)findGroupWithRemoteKey:(NSInteger)remoteKey
{
    for(GLPGroup *g in _groups)
    {
        if(remoteKey == g.remoteKey)
        {
            return g;
        }
    }
    
    return nil;
        
}



- (NSArray *)liveGroups
{
    return _groups;
}

@end
