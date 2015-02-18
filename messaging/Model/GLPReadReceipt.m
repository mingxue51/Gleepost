//
//  GLPReadReceipt.m
//  Gleepost
//
//  Created by Silouanos on 17/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPReadReceipt.h"
#import "GLPWebSocketEvent.h"
#import "UserManager.h"
#import "GLPUser.h"

@interface GLPReadReceipt ()

@property (assign, nonatomic) NSInteger messageRemoteKey;
@property (assign, nonatomic, getter=getConversationRemoteKey) NSInteger conversationRemoteKey;
@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic, readonly) NSString *prefixMessage;

@end

@implementation GLPReadReceipt

- (id)initWithWebSocketEvent:(GLPWebSocketEvent *)webSocketEvent
{
    if(self)
    {
        [self configureObjects];
        [self addUserWithRemoteKey:[webSocketEvent.data[@"user"] integerValue]];
        [self configureConversationRemoteKeyWithLocation:webSocketEvent.location];
        self.messageRemoteKey = [webSocketEvent.data[@"last_read"] integerValue];
        _prefixMessage = @"SEEN BY: "; 
    }
    
    return self;
}

#pragma mark - Configuration

- (void)configureObjects
{
    _users = [[NSMutableArray alloc] init];
}

- (void)configureConversationRemoteKeyWithLocation:(NSString *)location
{
    NSArray *locationData = [location componentsSeparatedByString:@"/"];
    
    NSString *conversationRemoteKeyString = [locationData lastObject];
    
    self.conversationRemoteKey = [conversationRemoteKeyString integerValue];
}

#pragma mark - Modifiers

- (void)addUserWithRemoteKey:(NSInteger)userRemoteKey
{
    if([self doesUserExistWitRemoteKey:userRemoteKey])
    {
        DDLogDebug(@"GLPReadReceipt : user already exists in read receipt abort.");
        return;
    }
    
    GLPUser *user = [UserManager getUserForRemoteKey:userRemoteKey];
    [_users addObject:(user) ? user : [[GLPUser alloc] initWithRemoteKey:userRemoteKey]];
}

/**
 This method should be only called when read receipt exists in GLPReadReceiptsManager.
 
 @param user the new user that have read the message.
 
 */
- (void)addUserWithUser:(GLPUser *)user
{
    if([self doesUserExistWitRemoteKey:user.remoteKey])
    {
        DDLogDebug(@"GLPReadReceipt : user already exists in read receipt abort.");
        return;
    }
    
    [_users addObject:user];
}

#pragma mark - Accessors

- (GLPUser *)getLastUser
{
    return [_users lastObject];
}

- (NSInteger)getMesssageRemoteKey
{
    return _messageRemoteKey;
}

- (NSString *)generateSeenMessage
{
    NSMutableString *userNames = self.prefixMessage.mutableCopy;
    
    NSUInteger finalCount = 0;
    
    if(_users.count > 3)
    {
        finalCount = 3;
    }
    else
    {
        finalCount = _users.count;
    }
    
    for(NSUInteger index = 0; index < finalCount; ++index)
    {
        GLPUser *user = [_users objectAtIndex:index];
        
        [userNames appendFormat:@"%@, ", user.name.uppercaseString];
    }
    
    if(_users.count > 3)
    {
        [userNames appendFormat:@"& %ld MORE...", (unsigned long)_users.count - 3];
    }
    else
    {
        NSRange removalRange;
        removalRange.length = 2;
        removalRange.location = userNames.length - 2;
        [userNames deleteCharactersInRange:removalRange];
    }
    
    return userNames;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"GLPReadReceipt %ld, %ld, users %@", (long)_conversationRemoteKey, (long)_messageRemoteKey, _users];
}

#pragma mark - Helpers

- (BOOL)doesUserExistWitRemoteKey:(NSInteger)userRemoteKey
{
    for(GLPUser *user in _users)
    {
        if(userRemoteKey == user.remoteKey)
        {
            return YES;
        }
    }
    
    return NO;
}


@end
