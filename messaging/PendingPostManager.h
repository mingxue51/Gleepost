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

typedef NS_ENUM(NSUInteger, KindOfPost) {
    kEventPost,
    kAnnouncementPost,
    kGeneralPost
};

@class GLPCategory;
@class GLPGroup;

@interface PendingPostManager : NSObject

+ (PendingPostManager *)sharedInstance;

- (BOOL)isGroupPost;
- (void)setGroupPost:(BOOL)groupPost;
- (void)setGroup:(GLPGroup *)group;
- (void)setCategory:(GLPCategory *)category;
- (void)setDate:(NSDate *)date;
- (void)setEventTitle:(NSString *)title;
- (void)setEventDescription:(NSString *)description;
- (void)setKindOfPost:(KindOfPost)kindOfPost;
- (NSString *)eventDescription;
- (NSString *)eventTitle;
- (NSDate *)getDate;
- (NSMutableArray *)categories;
- (KindOfPost)kindOfPost;
- (BOOL)isEventParty;
- (BOOL)isPostEvent;

- (BOOL)arePendingData;
- (GLPGroup *)group;
//- (void)setPendingData:(BOOL)pendingData;
- (void)reset;
- (void)readyToSend;

@end
