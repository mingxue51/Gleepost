//
//  CampusLiveManager.h
//  Gleepost
//
//  Created by Silouanos on 11/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CampusLiveManager : NSObject

+ (CampusLiveManager *)sharedInstance;

-(void)loadCurrentLivePostsWithCallbackBlock:(void (^) (BOOL success, NSArray *posts))callbackBlock;

-(int)findMostCloseToNowLivePostWithPosts:(NSArray *)posts;

@end
