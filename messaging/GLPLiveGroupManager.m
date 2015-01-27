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

#import "GLPLiveGroupManager.h"
#import "GLPGroupManager.h"
#import "WebClient.h"
#import "GLPGroupDao.h"
#import "ChangeGroupImageProgressView.h"
//#import "GLPGroupImageLoader.h"
#import "GLPGPPostImageLoader.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface GLPLiveGroupManager ()

@property (strong, nonatomic) dispatch_queue_t queue;

@property (strong, nonatomic) NSMutableArray *groups;

@property (strong, nonatomic) NSMutableDictionary *unreadPostGroups;

@property (strong, nonatomic) NSMutableDictionary *pendingGroupImagesProgressViews;

@property (strong, nonatomic) NSMutableDictionary *pendingGroupTimestamps;

/** This dictionary contains the pending groups with key, value: (group key, group). */
@property (strong, nonatomic) NSMutableDictionary *pendingGroups;

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
        _pendingGroups = [[NSMutableDictionary alloc] init];
        
        [self configureObservers];
        
//        _changeImageProgressView = [[ChangeGroupImageProgressView alloc] init];

    }
    
    return self;
}

- (void)configureObservers
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupAfterCreated:) name:GLPNOTIFICATION_NEW_GROUP_CREATED object:nil];
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_NEW_GROUP_CREATED object:nil];
}

/**
 This method should be called ONLY when the app is launced and from the current singleton class.
 */
- (void)loadInitialGroups
{
    DDLogInfo(@"Load groups");
    
    [GLPGroupManager loadGroups:_groups withLocalCallback:^(NSArray *groups) {
        _groups = groups.mutableCopy;
        [[GLPGPPostImageLoader sharedInstance] addGroups:_groups];
    } remoteCallback:^(BOOL success, NSArray *groups) {
        
        if(success)
        {
            _groups = groups.mutableCopy;
            [[GLPGPPostImageLoader sharedInstance] addGroups:_groups];
        }
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
            [self loadInitialGroups];
            break;
            
        default:
            break;
    }
}

- (void)getGroups
{
    dispatch_sync(_queue, ^{
        [self notifyWithUpdatedGroups];
    });
}

- (NSInteger)getPendingGroupKeyWithTimestamp:(NSDate *)timestamp
{
    GLPGroup *pendingGroup = [_pendingGroups objectForKey:timestamp];
    
    DDLogDebug(@"GLPLiveGroupManager : pending group key %d", pendingGroup.key);
    
    return pendingGroup.key;
}

- (void)loadGroupsWithPendingGroups:(NSArray *)pending withLiveCallback:(void (^) (NSArray* groups))local remoteCallback:(void (^) (BOOL success, NSArray *remoteGroups))remote
{
    //Find all the groups that contain real images and save them.
    NSMutableArray *pendingGroups = [[GLPGroupManager findGroupsWithRealImagesWithGroups:pending] mutableCopy];
    
    if(pendingGroups)
    {
        NSMutableArray *localEntities = [[GLPGroupDao findRemoteGroups] mutableCopy];
        _groups = localEntities;
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
        
//        [[GLPGroupImageLoader sharedInstance] addGroupsImages:_groups];
        [[GLPGPPostImageLoader sharedInstance] addGroups:_groups];
        
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

    [self clearUploadingNewImageToGroup:group];
    
    DDLogDebug(@"Pending group images: %@", _pendingGroupImagesProgressViews);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CHANGE_GROUP_IMAGE_FINISHED object:self userInfo:@{@"image_ready": group}];

}

- (void)clearUploadingNewImageToGroup:(GLPGroup *)group
{
    DDLogDebug(@"Pending group images before finishing: %@", _pendingGroupImagesProgressViews);
    
    [_pendingGroupImagesProgressViews removeObjectForKey:@(group.remoteKey)];
    
    [_pendingGroupTimestamps removeObjectForKey:@(group.remoteKey)];
}

- (NSDate *)timestampWithGroupRemoteKey:(NSInteger)groupRemoteKey
{
    return [_pendingGroupTimestamps objectForKey:@(groupRemoteKey)];
}

#pragma mark - Create group operations

- (void)newGroupToBeCreated:(GLPGroup *)pendingGroup withTimestamp:(NSDate *)timestamp
{
//    dispatch_async(_queue, ^{
    
    DDLogDebug(@"GLPLiveGroupManager : newGroupToBeCreated %@", pendingGroup);
    
    pendingGroup.sendStatus = kSendStatusLocal;
    [GLPGroupDao saveIfNotExist:pendingGroup];
    
    if(timestamp)
    {
        //Add pending group to pending groups and to groups' list.
        [_pendingGroups setObject:pendingGroup forKey:timestamp];
    }

    
    [_groups setObject:pendingGroup atIndexedSubscript:0];
    
    
    if(pendingGroup.pendingImage)
    {
        //Save pending image to cache.
        [[SDImageCache sharedImageCache] storeImage:pendingGroup.pendingImage forKey:[pendingGroup generatePendingIdentifier]];
    }
    
    [self notifyNewGroupToBeUploaded:pendingGroup];

//    });
}

- (void)updateGroupAfterCreated:(GLPGroup *)createdGroup
{
    //TODO: TEMPORARY CODE.
    [createdGroup.loggedInUser setRoleKey:9];
    [createdGroup.author setRoleKey:9];
    
    dispatch_async(_queue, ^{
        
        DDLogDebug(@"GLPLiveGroupManager : updateGroupAfterCreated %@", createdGroup);
        
//        GLPGroup *uploadedGroup = uploadedGroupNotification.userInfo[@"group"];
        
        
        [self removeGroupFromPendingDictionary:createdGroup];
        [self replaceGroupWithUpdatedGroup:createdGroup];
        
        DDLogDebug(@"UIIMAGE %@", [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[createdGroup generatePendingIdentifier]]);
        
        [[SDImageCache sharedImageCache] storeImage: [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[createdGroup generatePendingIdentifier]] forKey:createdGroup.groupImageUrl];
        
        [[SDImageCache sharedImageCache] removeImageForKey:[createdGroup generatePendingIdentifier]];

    });
    

    
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_NEW_GROUP_CREATED object:self userInfo:@{@"group":createdGroup}];

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

#pragma mark - NSNotifications

- (void)notifyWithUpdatedGroups
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_GROUPS_LOADED object:self userInfo:@{@"groups": _groups}];
}

- (void)notifyNewGroupToBeUploaded:(GLPGroup *)newGroup
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_NEW_GROUP_TO_BE_CREATED object:self userInfo:@{@"group": newGroup}];
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

- (void)removeGroupFromPendingDictionary:(GLPGroup *)group
{
    NSDate *timestampToBeDeleted = nil;
    
    for(NSDate *timestamp in _pendingGroups)
    {
        GLPGroup *g = [_pendingGroups objectForKey:timestamp];
        
        if(g.key == group.key)
        {
            timestampToBeDeleted = timestamp;
            break;
        }
    }
    
    if(!timestampToBeDeleted)
    {
        return;
    }
    
    [_pendingGroups removeObjectForKey:timestampToBeDeleted];
    
    DDLogDebug(@"GLPLiveGroupManager : removePendingGroup %@", _pendingGroups);
}

- (void)replaceGroupWithUpdatedGroup:(GLPGroup *)updatedGroup
{
    NSUInteger groupIndex = [_groups indexOfObject:updatedGroup];
    [_groups replaceObjectAtIndex:groupIndex withObject:updatedGroup];
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

@end
