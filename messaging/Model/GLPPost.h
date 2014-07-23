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
@property (strong, nonatomic) NSArray *videosUrls;
@property (strong, nonatomic) UIImage *tempImage;
@property (strong, nonatomic) UIImage *finalImage;
@property (assign, nonatomic) BOOL liked;
@property (assign, nonatomic) SendStatus sendStatus;
@property (strong, nonatomic) NSArray *categories;
@property (assign, nonatomic) int popularity;
@property (assign, nonatomic) NSInteger attendees;
@property (assign, nonatomic) BOOL attended;

//In case post has group information.
@property (strong, nonatomic) GLPGroup *group;

- (id)initWithRemoteKey:(NSInteger)remoteKey;
-(BOOL)imagePost;
-(BOOL)isGroupPost;
-(BOOL)isVideoPost;

@end
