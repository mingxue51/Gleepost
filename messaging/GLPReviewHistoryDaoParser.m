//
//  GLPReviewHistoryDaoParser.m
//  Gleepost
//
//  Created by Silouanos on 24/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPReviewHistoryDaoParser.h"
#import "GLPReviewHistory.h"
#import "FMDatabase.h"
#import "GLPEntityDaoParser.h"
#import "GLPUserDao.h"

@implementation GLPReviewHistoryDaoParser

+ (GLPReviewHistory *)parseResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    GLPReviewHistory *entity = [[GLPReviewHistory alloc] initWithAction:[resultSet intForColumn:@"action"] withDateHappened:[resultSet dateForColumn:@"date"] andReason:[resultSet stringForColumn:@"reason"]];
    
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    entity.user = [GLPUserDao findByRemoteKey:[resultSet intForColumn:@"user_remote_key"] db:db];
    
    return entity;
}

+ (GLPReviewHistory *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    return [GLPReviewHistoryDaoParser parseResultSet:resultSet inDb:db];
}

@end
