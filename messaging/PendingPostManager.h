//
//  PendingPostManager.h
//  Gleepost
//
//  Created by Σιλουανός on 14/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This singleton is used to preserve the data between the new post
//  view controllers. Once a post is canceled or created the singleton
//  releases all objects.

#import <Foundation/Foundation.h>

@class GLPCategory;

@interface PendingPostManager : NSObject

+ (PendingPostManager *)sharedInstance;

- (void)setCategory:(GLPCategory *)category;
- (void)setDate:(NSDate *)date;

@end
