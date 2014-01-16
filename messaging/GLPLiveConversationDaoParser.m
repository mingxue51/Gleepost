//
//  GLPLiveConversationDaoParser.m
//  Gleepost
//
//  Created by Σιλουανός on 28/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLiveConversationDaoParser.h"
#import "GLPLiveConversation.h"
#import "FMResultSet.h"
#import "GLPEntityDaoParser.h"


@implementation GLPLiveConversationDaoParser

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPLiveConversation *)entity
{
//    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
//    
//    entity.lastUpdate = [resultSet dateForColumn:@"lastUpdate"];
//    entity.title = [resultSet stringForColumn:@"title"];
//    entity.hasUnreadMessages = [resultSet boolForColumn:@"unread"];
//    entity.timeStarted = [resultSet dateForColumn:@"timeStarted"];
}

+ (GLPLiveConversation *)createFromResultSet:(FMResultSet *)resultSet
{
    GLPLiveConversation *entity = [[GLPLiveConversation alloc] init];
    [GLPLiveConversationDaoParser parseResultSet:resultSet into:entity];
    
    return entity;
}

@end
