//
//  GLPLiveGroupManager.h
//  Gleepost
//
//  Created by Σιλουανός on 29/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPLiveGroupManager : NSObject

+ (GLPLiveGroupManager *)sharedInstance;

- (void)loadGroups;

- (void)loadGroupsWithLiveCallback:(void (^) (NSArray* groups))local remoteCallback:(void (^) (BOOL success, NSArray *remoteGroups))remote;

- (NSArray *)liveGroups;

@end
