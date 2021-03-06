//
//  GLPPost.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPEntity.h"
#import "GLPUser.h"
#import "SendStatus.h"
#import "GLPGroup.h"
#import "GLPReviewHistory.h"
#import "GLPPoll.h"

@class GLPVideo;
@class GLPLocation;
@class GLPReviewHistory;

@interface GLPPost : GLPEntity

@property (assign, nonatomic) NSInteger likes;
@property (assign, nonatomic) NSInteger dislikes;
@property (assign, nonatomic) NSInteger commentsCount;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSDate *dateEventStarts;
@property (strong, nonatomic) NSString *eventTitle;
@property (strong, nonatomic) GLPUser *author;
@property (strong, nonatomic) NSArray *imagesUrls;
//This array is filled only if the post is waiting for approval.
@property (strong, nonatomic) NSMutableArray *reviewHistory;
@property (strong, nonatomic) NSMutableArray *usersLikedThePost;
//@property (strong, nonatomic) NSArray *videosUrls;
//@property (strong, nonatomic) NSString *videoThumbnail;
//@property (assign, nonatomic) NSNumber *pendingVideoKey;
/** If we are going to support multible videos change that to an array. */
@property (strong, nonatomic) GLPVideo *video;
@property (strong, nonatomic) GLPLocation *location;
@property (strong, nonatomic) GLPPoll *poll;
@property (strong, nonatomic) UIImage *tempImage;
@property (strong, nonatomic) UIImage *finalImage;
@property (assign, nonatomic) BOOL liked;
@property (assign, nonatomic) SendStatus sendStatus;
@property (strong, nonatomic) NSArray *categories;
@property (assign, nonatomic) NSInteger popularity;
@property (assign, nonatomic) NSInteger attendees;
@property (assign, nonatomic) BOOL attended;
@property (assign, nonatomic) NSInteger viewsCount;
//@property (assign, nonatomic, getter=isPending) BOOL pending;
@property (assign, nonatomic, getter=isPendingInEditMode) BOOL pendingInEditMode;

//In case post has group information.
@property (strong, nonatomic) GLPGroup *group;

- (id)initWithRemoteKey:(NSInteger)remoteKey;
- (void)addNewReviewHistory:(GLPReviewHistory *)reviewHistory;
-(BOOL)imagePost;
-(BOOL)isGroupPost;
-(BOOL)isVideoPost;
- (BOOL)isPollPost;
- (BOOL)isParty;
- (BOOL)isPostLiked;
- (BOOL)isPostCommented;
- (BOOL)isEvent;
- (void)updatePostWithNewPost:(GLPPost *)newPost;
- (void)addUserLikedThePost:(GLPUser *)user;
- (Action)pendingPostStatus;
- (NSDate *)generateDateEventEnds;
- (NSString *)locationDescription;

@end
