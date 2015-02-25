//
//  GLPConversationDaoParser.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPConversationDaoParser.h"
#import "GLPConversationDao.h"
#import "GLPEntityDaoParser.h"
#import "GLPUserDao.h"

@implementation GLPConversationDaoParser

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPConversation *)entity inDb:(FMDatabase *)db
{
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    entity.lastUpdate = [resultSet dateForColumn:@"lastUpdate"];
    entity.lastMessage = [resultSet stringForColumn:@"lastMessage"];
    entity.title = [resultSet stringForColumn:@"title"];
    entity.hasUnreadMessages = [resultSet boolForColumn:@"unread"];
    entity.isGroup = [resultSet boolForColumn:@"isGroup"];
    entity.isLive = [resultSet boolForColumn:@"isLive"];
    
    // get participants
    NSArray *participantsKeys = [[resultSet stringForColumn:@"participants_keys"] componentsSeparatedByString:@";"];
    NSMutableArray *participants = [NSMutableArray array];
    for(NSString *key in participantsKeys) {
        GLPUser *user = [GLPUserDao findByKey:[key integerValue] db:db];
        NSAssert(user, @"User from conversation participants must not be null");
        [participants addObject:user];
    }

    entity.participants = participants;
    
    // parse reads.
    [entity setReads:[GLPConversationDao findReadsWithConversation:entity andDb:db]];
    
    entity.groupRemoteKey = [resultSet intForColumn:@"group_remote_key"];
    
}

+ (GLPConversation *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    GLPConversation *entity = [[GLPConversation alloc] init];
    [GLPConversationDaoParser parseResultSet:resultSet into:entity inDb:db];
    
    return entity;
}

@end