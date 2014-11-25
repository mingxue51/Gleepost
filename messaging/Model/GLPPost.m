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

-(NSString *)description
{
    return [NSString stringWithFormat:@"Post id: %ld, Content: %@ Sending status: %d Date: %@, Group: %@ ", (long)self.remoteKey, self.content, self.sendStatus, self.date, self.group];
}



@end
