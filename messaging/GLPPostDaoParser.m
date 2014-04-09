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
#import "GLPCategoryDao.h"

@implementation GLPPostDaoParser

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPPost *)entity inDb:(FMDatabase *)db
{
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    entity.content = [resultSet stringForColumn:@"content"];
    entity.date = [resultSet dateForColumn:@"date"];
    entity.likes = [resultSet intForColumn:@"likes"];
    entity.dislikes = [resultSet intForColumn:@"dislikes"];
    entity.commentsCount = [resultSet intForColumn:@"comments"];
    entity.liked = [resultSet boolForColumn:@"liked"];
    entity.attended = [resultSet boolForColumn:@"attending"];
    
    entity.author = [GLPUserDao findByRemoteKey:[resultSet intForColumn:@"author_key"] db:db];
    
    entity.categories = [GLPCategoryDao findByPostRemoteKey:entity.remoteKey db:db];
}

+ (GLPPost *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    GLPPost *entity = [[GLPPost alloc] init];
    [GLPPostDaoParser parseResultSet:resultSet into:entity inDb:db];
    
    return entity;
}

@end
