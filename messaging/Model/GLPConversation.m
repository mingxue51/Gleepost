//
//  GLPConversation.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPConversation.h"
#import "SessionManager.h"
#import "NSDate+TimeAgo.h"
#import "GLPMessage.h"

@implementation GLPConversation

@synthesize lastUpdate = _lastUpdate;
@synthesize lastMessage = _lastMessage;
@synthesize messages = _messages;
@synthesize participants = _participants;
@synthesize title = _title;
@synthesize hasUnreadMessages = _hasUnreadMessages;
@synthesize isGroup = _isGroup;
@synthesize isLive = _isLive;
@synthesize expiryDate=_expiryDate;
@synthesize isEnded=_isEnded;

// Init regular conversation from database
// It will be populated afterwards
// TODO: Should implement constructor with all args for better reliability
- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _messages = [NSMutableArray array];
    
    return self;
}

// Init new regular conversation
- (id)initWithParticipants:(NSArray *)participants
{
    self = [self init];
    if(!self) {
        return nil;
    }
    
    // participants contains at least current user and another one
    NSAssert(participants.count >= 2, @"Participants must contain at least current user and another one");
    
    // remove the current user
    _participants = [participants filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"remoteKey != %d", [SessionManager sharedInstance].user.remoteKey]];
    
    _isGroup = _participants.count > 1;
    _title = _isGroup ? @"Group chat" : [self getUniqueParticipant].name;
    
    _isLive = NO;
    _isEnded = NO;
    _hasUnreadMessages = NO;

    return self;
}

// Init new live conversation
- (id)initWithParticipants:(NSArray *)participants expiryDate:(NSDate *)expiryDate ended:(BOOL)ended
{
    self = [self initWithParticipants:participants];
    if(!self) {
        return nil;
    }
    
    _isLive = YES;
    _isEnded = ended;
    _expiryDate = expiryDate;
    
    return self;
}

- (GLPUser *)getUniqueParticipant
{
    NSAssert(!_isGroup, @"Cannot get unique participant on group conversation");
    return _participants[0];
}

- (NSString *)getLastMessageOrDefault
{
    return _lastMessage ? _lastMessage : @"";
}

- (NSString *)getLastUpdateOrDefault
{
    return _lastUpdate ? [_lastUpdate timeAgo] : @"";
}

- (void)updateWithNewMessage:(GLPMessage *)message
{
    _lastMessage = message.content;
    _lastUpdate = message.date;
    
    if(_isLive) {
        [_messages addObject:message];
    }
}

@end
