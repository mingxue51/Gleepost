//
//  GLPPost.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPost.h"
#import "GLPVideo.h"
#import "DateFormatterHelper.h"
#import "GLPLocation.h"
#import "GLPReviewHistory.h"
#import "GLPCategory.h"

@implementation GLPPost

@synthesize likes;
@synthesize dislikes;
@synthesize commentsCount;
@synthesize content;
@synthesize date;
@synthesize author;
@synthesize imagesUrls;
@synthesize sendStatus=_sendStatus; 
//@synthesize liked=_liked;

- (id)init
{
    self = [super init];
    if(!self) {
        return self;
    }
    
    _sendStatus = kSendStatusLocal;
    _pendingInEditMode = NO;
    _viewsCount = 0;
    self.usersLikedThePost = [[NSMutableArray alloc] init];

    return self;
}

- (id)initWithRemoteKey:(NSInteger)remoteKey
{
    self = [super init];
    
    if(self)
    {
        self.remoteKey = remoteKey;
        _pendingInEditMode = NO;
        _viewsCount = 0;
        self.usersLikedThePost = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - Modifiers

- (void)addNewReviewHistory:(GLPReviewHistory *)reviewHistory
{
    if (self.reviewHistory == nil)
    {
        self.reviewHistory = [[NSMutableArray alloc] initWithObjects:reviewHistory, nil];
    }
    else
    {
        [self.reviewHistory addObject:reviewHistory];
    }
}

#pragma mark - Accessors

-(BOOL)imagePost
{
    if (imagesUrls == nil || [imagesUrls count] == 0)
    {
        return NO;
    }
        
    return YES;
}

-(BOOL)isVideoPost
{
    if(_video == nil)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)isPollPost
{
    if(_poll == nil)
    {
        return NO;
    }
    
    return YES;
}

-(BOOL)isGroupPost
{
    if(_group != nil)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isParty
{
    for(GLPCategory *c in self.categories)
    {
        if([c.tag isEqualToString:@"party"])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isEvent
{
    return self.eventTitle != nil;
}

- (Action)pendingPostStatus
{
    if(!self.reviewHistory || self.reviewHistory.count == 0)
    {
        return kPending;
    }
    else
    {
        GLPReviewHistory *firstReviewHistory = [self.reviewHistory lastObject];
        
        return [firstReviewHistory action];
    }
    
}

/**
 Updates the current post with new data if there are from the newPost.
 
 @param the new updated post.
 
 */
- (void)updatePostWithNewPost:(GLPPost *)newPost
{
    self.eventTitle = newPost.eventTitle;
    
    self.dateEventStarts = newPost.dateEventStarts;
    
    self.content = newPost.content;
    
    self.imagesUrls = newPost.imagesUrls;
    
    self.video = newPost.video;
}

- (BOOL)isPostLiked
{
    return self.likes > 0;
}

- (BOOL)isPostCommented
{
    return self.commentsCount > 0;
}

- (void)addUserLikedThePost:(GLPUser *)user
{
    [self.usersLikedThePost addObject:user];
}

- (NSDate *)generateDateEventEnds
{
    return [DateFormatterHelper addHours:2 toDate:_dateEventStarts];
}

- (NSString *)locationDescription
{
    if(!_location.name)
    {
        return _location.address;
    }
    
    return _location.name;
}

- (BOOL)isEqual:(id)other
{
//    if (other == self) {
//        DDLogDebug(@"GLPPost : equal YES %d %@ : %@", [(GLPPost *)other remoteKey] == self.remoteKey, [(GLPPost *)other content], self.content);
//        return YES;
//    } else if (![super isEqual:other]) {
//        DDLogDebug(@"GLPPost : equal NO %d %@ : %@", [(GLPPost *)other remoteKey] == self.remoteKey, [(GLPPost *)other content], self.content);
//        return NO;
//    } else {
//        DDLogDebug(@"GLPPost : equal %d %@ : %@", [(GLPPost *)other remoteKey] == self.remoteKey, [(GLPPost *)other content], self.content);
//        
//        return [(GLPPost *)other remoteKey] == self.remoteKey;
//    }
    
//    DDLogDebug(@"GLPPost : equal %d %@ : %@", [(GLPPost *)other remoteKey] == self.remoteKey, [(GLPPost *)other content], self.content);

    return [(GLPPost *)other remoteKey] == self.remoteKey;

}

- (NSUInteger)hash
{
    return self.remoteKey;
}

#pragma mark - Copy

-(id)copyWithZone:(NSZone *)zone
{
    DDLogDebug(@"GLPPost : copyWithZone %@", zone);
    
    GLPPost *post = [[self class] allocWithZone:zone];
    post.likes = self.likes;
    post.commentsCount = self.commentsCount;
    post.content = [self.content copyWithZone:zone];
    post.date = [self.date copyWithZone:zone];
    post.dateEventStarts = [self.dateEventStarts copyWithZone:zone];
    post.eventTitle = [self.eventTitle copyWithZone:zone];
    post.author = [self.author copyWithZone:zone];
    post.imagesUrls = [self.imagesUrls copyWithZone:zone];
    post.reviewHistory = [self.reviewHistory copyWithZone:zone];
    post.video = [self.video copyWithZone:zone];
    post.location = [self.location copyWithZone:zone];
//    post.tempImage = [self.tempImage copy:nil];
//    post.finalImage = self.finalImage;
    post.liked = self.liked;
    post.sendStatus = self.sendStatus;
    post.categories = [self.categories copyWithZone:zone];
    post.popularity = self.popularity;
    post.attendees = self.attendees;
    post.attended = self.attended;
    post.viewsCount = self.viewsCount;
    post.pendingInEditMode = self.pendingInEditMode;
    
    return post;
}

-(NSString *)description
{
//    return [NSString stringWithFormat:@"Post id: %ld, Content: %@ Sending status: %d Date: %@, Group: %@, SendStatus %d, Event date: %@", (long)self.remoteKey, self.content, self.sendStatus, self.date, self.group, self.sendStatus, self.dateEventStarts];
    
    return [NSString stringWithFormat:@"Post content %@, remote key %d Views count %d", self.content, self.remoteKey, self.viewsCount];
}

@end
