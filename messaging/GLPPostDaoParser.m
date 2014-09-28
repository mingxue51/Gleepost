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
#import "GLPLocation.h"
#import "GLPGroupDao.h"

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
    entity.eventTitle = [resultSet stringForColumn:@"event_title"];
    entity.dateEventStarts = [resultSet dateForColumn:@"event_date"];
    entity.sendStatus = [resultSet intForColumn:@"sendStatus"];
    entity.author = [GLPUserDao findByRemoteKey:[resultSet intForColumn:@"author_key"] db:db];
    entity.categories = [GLPCategoryDao findByPostRemoteKey:entity.remoteKey db:db];
    
    //Parse group remote key if exists. If group remote key is 0 then the post is a campus wall post.
    entity.group = [GLPGroupDao findByRemoteKey:[resultSet intForColumn:@"group_remote_key"] db:db];
        
    //Parse location.
    entity.location = [GLPPostDaoParser parseLocationWithResultSet:resultSet];
}

+ (GLPLocation *)parseLocationWithResultSet:(FMResultSet *)resultSet
{
    NSString *name = [resultSet stringForColumn:@"location_name"];
    NSString *address = [resultSet stringForColumn:@"location_address"];
    double latitude = [resultSet doubleForColumn:@"location_lat"];
    double longitude = [resultSet doubleForColumn:@"location_lon"];
    
    if(!name)
    {
        return nil;
    }
    
    return [[GLPLocation alloc] initWithName:name address:address latitude:latitude longitude:longitude];
}

+ (GLPPost *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    GLPPost *entity = [[GLPPost alloc] init];
    [GLPPostDaoParser parseResultSet:resultSet into:entity inDb:db];
    
    return entity;
}

@end
