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
    GLPUser *user = [GLPUserDao findByRemoteKey:[resultSet intForColumn:@"user_remote_key"] db:db];
    
    GLPReviewHistory *entity = [[GLPReviewHistory alloc] initWithAction:[resultSet intForColumn:@"action"] withDateHappened:[resultSet dateForColumn:@"date"] reason:[resultSet stringForColumn:@"reason"] andUser:user];
    
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    
    return entity;
}

+ (GLPReviewHistory *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    return [GLPReviewHistoryDaoParser parseResultSet:resultSet inDb:db];
}

@end
