//
//  GLPCommentDaoParser.m
//  Gleepost
//
//  Created by Silouanos on 25/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCommentDaoParser.h"
#import "GLPEntityDaoParser.h"
#import "GLPUserDao.h"

@implementation GLPCommentDaoParser

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPComment *)entity inDb:(FMDatabase *)db
{
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    entity.content = [resultSet stringForColumn:@"content"];
    entity.date = [resultSet dateForColumn:@"date"];
    
    entity.author = [GLPUserDao findByRemoteKey:[resultSet intForColumn:@"user_remote_key"] db:db];
//    entity.post = []

}

+ (GLPComment *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    GLPComment *entity = [[GLPComment alloc] init];
    [GLPCommentDaoParser parseResultSet:resultSet into:entity inDb:db];
    
    return entity;
}

@end
