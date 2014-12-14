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
    _pending = NO;
    return self;
}

- (id)initWithRemoteKey:(NSInteger)remoteKey
{
    self = [super init];
    
    if(self)
    {
        self.remoteKey = remoteKey;
        _pending = NO;
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

-(BOOL)isGroupPost
{
    if(_group != nil)
    {
        return YES;
    }
    
    return NO;
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
    
    DDLogDebug(@"GLPPost : equal %d %@ : %@", [(GLPPost *)other remoteKey] == self.remoteKey, [(GLPPost *)other content], self.content);

    return [(GLPPost *)other remoteKey] == self.remoteKey;

}

- (NSUInteger)hash
{
    return self.remoteKey;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"Post id: %ld, Content: %@ Sending status: %d Date: %@, Group: %@, SendStatus %d, Event date: %@", (long)self.remoteKey, self.content, self.sendStatus, self.date, self.group, self.sendStatus, self.dateEventStarts];
}



@end
