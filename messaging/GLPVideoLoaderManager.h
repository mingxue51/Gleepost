//
//  GLPVideoLoaderManager.h
//  Gleepost
//
//  Created by Silouanos on 23/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBJVideoPlayerController;

@interface GLPVideoLoaderManager : NSObject

+ (GLPVideoLoaderManager *)sharedInstance;


-(void)addVideoPosts:(NSArray *)posts;
-(PBJVideoPlayerController *)addVideoWithUrl:(NSString *)videoUrl andPostRemoteKey:(NSInteger)remoteKey;
-(PBJVideoPlayerController *)videoWithPostRemoteKey:(NSInteger)remoteKey;


@end
