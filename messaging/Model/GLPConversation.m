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

- (id)initFromGroup:(NSInteger)groupRemoteKey withRemoteKey:(NSInteger)remoteKey
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.remoteKey = remoteKey;
    _isFromPushNotification = YES;
    _groupRemoteKey = groupRemoteKey;
    _title = @"Loading conversation";
    
    return self;
}

- (id)initGroupsConversationWithParticipants:(NSArray *)participants
{
    self = [self init];
    
    if(self)
    {
        _participants = participants;
    }
    
    return self;
}

// Init new regular conversation
- (id)initWithParticipants:(NSArray *)participants
{
    self = [self init];
    if(!self) {
        return nil;
    }
    
    // participants contains at least current user and another one // there is no need for that.
//    NSAssert(participants.count >= 2, @"Participants must contain at least current user and another one");
    
    // remove the current user // there is no need for that.
    _participants = [participants filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"remoteKey != %d", [SessionManager sharedInstance].user.remoteKey]];
    
    _isGroup = _participants.count > 1;
    
    _title = _isGroup ? [self generateGroupTitle] : [self getUniqueParticipant].name;
    
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

- (NSString *)getLastMessagesContentOrDefault
{
    return _lastMessage ? _lastMessage : @"";
}

- (NSString *)getLastUpdateOrDefault
{
    return _lastUpdate ? [_lastUpdate timeAgo] : @"";
}

- (void)updateWithNewMessage:(GLPMessage *)message
{
//    _lastMessage = message.content;
    _lastMessage = [message getReadableContent];
    _lastUpdate = message.date;
}

/**
 Checks and sets the conversation as unread if the updated conversation's last
 message is not the same with the current's.
 
 @param updatedConversation
 
 @return YES if there is an unread message, otherwise NO.
 
 */
- (BOOL)setUnreadMessageWithUpdatedConversation:(GLPConversation *)updatedConversation
{
    if(self.lastMessage == nil || updatedConversation.lastMessage == nil)
    {
        return NO;
    }
    
    if(![self.lastMessage isEqualToString:updatedConversation.lastMessage])
    {
        DDLogDebug(@"setUnreadMessageWithUpdatedConversation %@ : %@", self.lastMessage, updatedConversation.lastMessage);
        
        self.hasUnreadMessages = YES;
        
        return YES;
    }
    
    return NO;
}

- (BOOL)isGroupMessenger
{
    if(_groupRemoteKey != 0)
    {
        return YES;
    }
    
    return NO;
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
    object.reads = [_reads copyWithZone:zone];
    
    return object;
}

# pragma mark - Other

-(NSString *)description
{
    return [NSString stringWithFormat:@"Remote Key: %ld, Message: %@, Participants: %@, Reads %@", (long)self.remoteKey, _lastMessage, self.participants, self.reads];
}

- (NSString *)generateGroupTitle
{
    NSMutableString *participantsNames = [[NSMutableString alloc] init];
    
    
    for(GLPUser *user in _participants)
    {
        [participantsNames appendFormat:@"%@, ", user.name];
    }
    
    [participantsNames deleteCharactersInRange:NSMakeRange(participantsNames.length - 2, 2)];
    
    return participantsNames;

}


@end
