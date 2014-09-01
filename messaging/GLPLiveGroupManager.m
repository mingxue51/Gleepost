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

- (void)loadGroupsWithLiveCallback:(void (^) (NSArray* groups))local remoteCallback:(void (^) (BOOL success, NSArray *remoteGroups))remote
{
    local(_groups);
    
    [[WebClient sharedInstance ] getGroupswithCallbackBlock:^(BOOL success, NSArray *serverGroups) {
        
        if(!success) {
            remote(NO, nil);
            return;
        }
        
        //Store only groups that are not exist into the database.
        
        [GLPGroupDao saveGroups:serverGroups];
        
        _groups = [serverGroups mutableCopy];
        
        remote(YES, _groups);
    }];
}

- (NSArray *)liveGroups
{
    return _groups;
}

@end
