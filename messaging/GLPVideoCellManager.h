//
//  GLPVideoCellManager.h
//  Gleepost
//
//  Created by Σιλουανός on 26/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBJVideoPlayerController.h"

@class AVURLAsset;

@interface GLPVideoCellManager : NSObject <PBJVideoPlayerControllerDelegate>

- (id)initWithAsset:(AVURLAsset *)asset andRemoteKey:(NSInteger)remoteKey;
- (id)initWithRemoteKey:(NSInteger)remoteKey;
- (void)setAsset:(AVURLAsset *)asset;
- (BOOL)containsAsset;
@end
