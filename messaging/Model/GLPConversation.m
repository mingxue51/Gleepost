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

// Init conversation from database
- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _messages = [NSMutableArray array];
    
    return self;
}

// Init new normal conversation
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
    
//    NSLog(@"Participants to the conversation");
//    for(GLPUser *user in _participants) {
//        NSLog(@"%@", user.name);
//    }
    
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

//- (void)setTitleFromParticipants:(NSArray *)participants
//{
//    NSAssert(participants.count > 1, @"");
//    
//    
//    _participants = participants;
//    
//    NSMutableString *names = [NSMutableString string];
//    
//    NSMutableArray *filteredParticipants = [NSMutableArray arrayWithCapacity:participants.count - 1];
//    for(GLPUser *user in participants) {
//        if(![user isEqualToEntity:[SessionManager sharedInstance].user]) {
//            [filteredParticipants addObject:user];
//        }
//    }
//    
//    [filteredParticipants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        GLPUser *user = obj;
//        [names appendString:user.name];
//        
//        if(filteredParticipants.count > 1 && idx != filteredParticipants.count - 1) {
//            if(idx == filteredParticipants.count - 2) {
//                [names appendString:@" and "];
//            } else {
//                [names appendString:@", "];
//            }
//        }
//    }];
//    
//    self.title = names;
//}
// Excludes the current user name
//- (NSString *)getParticipantsNames
//{
//    NSMutableString *names = [NSMutableString string];
//    
//    if(self.participants.count < 2) {
//        return @"Invalid conversation";
//    }
//    
//    NSMutableArray *filteredParticipants = [NSMutableArray arrayWithCapacity:self.participants.count - 1];
//    
//    for(GLPUser *user in self.participants) {
//        if(![user isEqualToEntity:[SessionManager sharedInstance].user]) {
//            [filteredParticipants addObject:user];
//        }
//    }
//    
//    [filteredParticipants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        GLPUser *user = obj;
//        [names appendString:user.name];
//        
//        if(filteredParticipants.count > 1 && idx != filteredParticipants.count - 1) {
//            if(idx == filteredParticipants.count - 2) {
//                [names appendString:@" and "];
//            } else {
//                [names appendString:@", "];
//            }
//        }
//    }];
//    
//    return names;
//}

@end
