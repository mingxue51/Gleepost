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
@synthesize lastSyncMessageKey=_lastSyncMessageKey;
@synthesize isFromPushNotification=_isFromPushNotification;

// Init regular conversation from database
// It will be populated afterwards
- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _messages = [NSMutableArray array];
    _isFromPushNotification = NO;
    
    return self;
}

- (id)initFromPushNotificationWithRemoteKey:(NSInteger)remoteKey
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.remoteKey = remoteKey;
    _isFromPushNotification = YES;
    _title = @"Loading conversation";
    
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
    
//    _isGroup = _participants.count > 1;
    _isGroup = _participants.count > 1;

    DDLogDebug(@"Participants: %@", _participants);
    
    _title = _isGroup ? @"Group chat" : [self getUniqueParticipant].name;
    
    _isLive = NO;
    _isEnded = NO;
    _hasUnreadMessages = NO;
    
    _lastSyncMessageKey = NSNotFound;
    
    _isFromPushNotification = NO;

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
}

# pragma mark - Copy

-(id)copyWithZone:(NSZone *)zone
{
    GLPConversation *object = [super copyWithZone:zone];
    object.lastMessage = [_lastMessage copyWithZone:zone];
    object.lastUpdate = [_lastUpdate copyWithZone:zone];
    object.participants = [_participants copyWithZone:zone];
    object.title = [_title copyWithZone:zone];
    object.hasUnreadMessages = _hasUnreadMessages;
    object.isGroup = _isGroup;
    object.isLive = _isLive;
    object.lastSyncMessageKey = _lastSyncMessageKey;
    object.isEnded = _isEnded;
    object.expiryDate = [_expiryDate copyWithZone:zone];
    
    return object;
}

# pragma mark - Other

-(NSString *)description
{
    return [NSString stringWithFormat:@"Remote Key: %ld, Message: %@, Participants: %@", (long)self.remoteKey, _lastMessage, self.participants];
}


@end
