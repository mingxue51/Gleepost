//
//  GLPMessageDaoParser.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPMessageDaoParser.h"
#import "GLPEntityDaoParser.h"
#import "GLPConversationDao.h"
#import "GLPUserDao.h"

@implementation GLPMessageDaoParser

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPMessage *)entity
{
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    entity.content = [resultSet stringForColumn:@"content"];
    entity.date = [resultSet dateForColumn:@"date"];
    entity.sendStatus = [resultSet intForColumn:@"sendStatus"];
    
    entity.conversation = [GLPConversationDao findByRemoteKey:[resultSet intForColumn:@"conversation_key"]];
    entity.author = [GLPUserDao findByRemoteKey:[resultSet intForColumn:@"author_key"]];
}

+ (GLPMessage *)createFromResultSet:(FMResultSet *)resultSet
{
    GLPMessage *entity = [[GLPMessage alloc] init];
    [GLPMessageDaoParser parseResultSet:resultSet into:entity];
    
    return entity;
}

@end
