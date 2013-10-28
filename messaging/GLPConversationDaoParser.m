//
//  GLPConversationDaoParser.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPConversationDaoParser.h"
#import "GLPEntityDaoParser.h"
#import "GLPUserDao.h"

@implementation GLPConversationDaoParser

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPConversation *)entity
{
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    entity.lastUpdate = [resultSet dateForColumn:@"lastUpdate"];
    entity.lastMessage = [resultSet stringForColumn:@"lastMessage"];
    entity.title = [resultSet stringForColumn:@"title"];
    entity.hasUnreadMessages = [resultSet boolForColumn:@"unread"];
    // get participants from json id
//    NSMutableArray *participants = [NSMutableArray array];
//    NSArray *participantsKeys = [[resultSet stringForColumn:@"participants"] componentsSeparatedByString:@","];
//    for(NSString *key in participantsKeys) {
//        [participants addObject:[GLPUserDao findByRemoteKey:[key integerValue]]];
//    }
//    entity.participants = participants;
    
    // get participants names
//    NSMutableArray *participants = [NSMutableArray array];
//    NSArray *participantsKeys = [[resultSet stringForColumn:@"participants"] componentsSeparatedByString:@","];
//    for(NSString *key in participantsKeys) {
//        [participants addObject:[GLPUserDao findByRemoteKey:[key integerValue]]];
//    }
//    
//    entity.participantsNames = [[resultSet stringForColumn:@"participants_names"] componentsSeparatedByString:@","];

}

+ (GLPConversation *)createFromResultSet:(FMResultSet *)resultSet
{
    GLPConversation *entity = [[GLPConversation alloc] init];
    [GLPConversationDaoParser parseResultSet:resultSet into:entity];
    
    return entity;
}

@end