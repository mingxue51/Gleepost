//
//  GLPLiveGroupManager.m
//  Gleepost
//
//  Created by Σιλουανός on 29/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This manager is a singleton and it works (in co-operation with GLPGroupManager) once the app launced.
//  The aim of this manager is to pre-fetch all the groups before viewing the groups' tab
//  and in general to handle all the group operations such changing image progress bar.
//

#import "GLPLiveGroupManager.h"
#import "GLPGroupManager.h"
#import "WebClient.h"
#import "GLPGroupDao.h"
#import "ChangeGroupImageProgressView.h"
#import "GLPGroupImageLoader.h"

@interface GLPLiveGroupManager ()

@property (strong, nonatomic) dispatch_queue_t queue;

@property (strong, nonatomic) NSMutableArray *groups;

@property (strong, nonatomic) NSMutableDictionary *unreadPostGroups;

@property (strong, nonatomic) NSMutableDictionary *pendingGroupImagesProgressViews;

@property (strong, nonatomic) NSMutableDictionary *pendingGroupTimestamps;

//@property (strong, nonatomic) ChangeGroupImageProgressView *changeImageProgressView;

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
        _pendingGroupImagesProgressViews = [[NSMutableDictionary alloc] init];
        _pendingGroupTimestamps = [[NSMutableDictionary alloc] init];
//        _changeImageProgressView = [[ChangeGroupImageProgressView alloc] init];

    }
    
    return self;
}

/**
 This method should be called ONLY when the app is launced and from the current singleton class.
 */
- (void)loadGroups
{
    DDLogInfo(@"Load groups");
    
    [GLPGroupManager loadGroups:_groups withLocalCallback:^(NSArray *groups) {
        
        _groups = groups.mutableCopy;
        
        [[GLPGroupImageLoader sharedInstance] addGroupsImages:_groups];

        
    } remoteCallback:^(BOOL success, NSArray *groups) {
        
        _groups = groups.mutableCopy;
        
        [[GLPGroupImageLoader sharedInstance] addGroupsImages:_groups];

        
    }];
}

/**
 Reloads the groups in case the notification has to do with groups.
 NOTE: This method should be called only from web socket event.
 
 @param notification the new notification.
 
 */
- (void)loadGroupsIfNeededWithNewNotification:(GLPNotification *)notification
{
    switch (notification.notificationType)
    {
        case kGLPNotificationTypeCreatedPostGroup:
        case kGLPNotificationTypeInvitedYouToGroup:
            [self loadGroups];
            break;
            
        default:
            break;
    }
}

- (void)loadGroupsWithPendingGroups:(NSArray *)pending withLiveCallback:(void (^) (NSArray* groups))local remoteCallback:(void (^) (BOOL success, NSArray *remoteGroups))remote
{
    
    //Find all the groups that contain real images and save them.
    NSMutableArray *pendingGroups = [[GLPGroupManager findGroupsWithRealImagesWithGroups:pending] mutableCopy];
    

    if(pendingGroups)
    {
        NSMutableArray *localEntities = [[GLPGroupDao findRemoteGroups] mutableCopy];
        
        _groups = localEntities;
        
        for(GLPGroup *group in _groups)
        {
            DDLogDebug(@"Local group %d", group.remoteKey);
        }
        

        [self addPendingGroupsIfNeededToLocalGroups:pendingGroups];
    }
    
    local(_groups);
    
    [[WebClient sharedInstance ] getGroupswithCallbackBlock:^(BOOL success, NSArray *serverGroups) {
        
        if(!success) {
            remote(NO, nil);
            return;
        }
    
        //Store only groups that are not exist into the database.
        
        [GLPGroupDao saveGroups:serverGroups];
        
        _groups = [serverGroups mutableCopy];
        
        [self addPendingGroupsIfNeededToLocalGroups:pendingGroups];
        
        [[GLPGroupImageLoader sharedInstance] addGroupsImages:_groups];
        
        remote(YES, _groups);
    }];
}

- (void)addPendingGroupsIfNeededToLocalGroups:(NSMutableArray *)pendingGroups
{
    NSMutableArray *notPendingGroups = [[NSMutableArray alloc] init];
    
    for(GLPGroup *pGroup in pendingGroups)
    {
        NSArray *groupsFound = [_groups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"key == %d", pGroup.key]];
        [notPendingGroups addObjectsFromArray:groupsFound];
    }
    
    [pendingGroups removeObjectsInArray:notPendingGroups];
    
    [_groups addObjectsFromArray:pendingGroups];
}

//- (NSMutableArray *)addPendingGroupsIfNeededToRemoteGroups:(NSMutableArray *)pendingGroups
//{
//    
//}

- (GLPGroup *)groupWithRemoteKey:(NSInteger)groupRemoteKey
{
    DDLogDebug(@"GROUPS!!! : %@", _groups);
    
    return [self findGroupWithRemoteKey:groupRemoteKey];
    
}

#pragma mark - Image uploading progress

- (ChangeGroupImageProgressView *)progressViewWithGroup:(GLPGroup *)group
{
    DDLogDebug(@"Pending group images get progress: %@", _pendingGroupImagesProgressViews);

    
    ChangeGroupImageProgressView *groupImageProgressView = [_pendingGroupImagesProgressViews objectForKey:@(group.remoteKey)];
    
    return groupImageProgressView;
    
    
//    if(_changeImageProgressView.group.remoteKey != group.remoteKey)
//    {
//        return nil;
//    }
    
//    return _changeImageProgressView;
}

- (void)startChangeImageProgressingWithGroup:(GLPGroup *)group
{
    ChangeGroupImageProgressView *groupImageProgressView = [[ChangeGroupImageProgressView alloc] init];
    
    [groupImageProgressView setGroup:group];
    
    [_pendingGroupImagesProgressViews setObject:groupImageProgressView forKey:@(group.remoteKey)];
    
    [_pendingGroupTimestamps setObject:[NSDate date] forKey:@(group.remoteKey)];
    
//    [_changeImageProgressView setGroup:group];
}

- (void)finishUploadingNewImageToGroup:(GLPGroup *)group
{
    DDLogDebug(@"Pending group images before finishing: %@", _pendingGroupImagesProgressViews);
    
    [_pendingGroupImagesProgressViews removeObjectForKey:@(group.remoteKey)];
    
    [_pendingGroupTimestamps removeObjectForKey:@(group.remoteKey)];
    
    DDLogDebug(@"Pending group images: %@", _pendingGroupImagesProgressViews);
}

- (NSDate *)timestampWithGroupRemoteKey:(NSInteger)groupRemoteKey
{
    return [_pendingGroupTimestamps objectForKey:@(groupRemoteKey)];
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

#pragma mark - Helpers

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
    NSArray *groupsFound = [_groups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"remoteKey == %d", remoteKey]];

    if(groupsFound.count > 0)
    {
        DDLogDebug(@"GLPLiveGroupManager : groups found %@", groupsFound);
        
        return [groupsFound firstObject];
    }
    
    return nil;
}

- (NSArray *)liveGroups
{
    return _groups;
}

@end
