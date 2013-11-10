//
//  GLPPostDaoParser.m
//  Gleepost
//
//  Created by Lukas on 11/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPostDaoParser.h"
#import "GLPEntityDaoParser.h"
#import "FMResultSet.h"
#import "GLPUserDao.h"

@implementation GLPPostDaoParser

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPPost *)entity inDb:(FMDatabase *)db
{
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    entity.content = [resultSet stringForColumn:@"content"];
    entity.date = [resultSet dateForColumn:@"date"];
    entity.likes = [resultSet intForColumn:@"likes"];
    entity.dislikes = [resultSet intForColumn:@"dislikes"];
    entity.commentsCount = [resultSet intForColumn:@"comments"];
    
    entity.author = [GLPUserDao findByRemoteKey:[resultSet intForColumn:@"author_key"] db:db];
}

+ (GLPPost *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    GLPPost *entity = [[GLPPost alloc] init];
    [GLPPostDaoParser parseResultSet:resultSet into:entity inDb:db];
    
    return entity;
}

@end
