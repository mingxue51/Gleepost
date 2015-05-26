//
//  GLPLiveSummaryDao.m
//  Gleepost
//
//  Created by Silouanos on 26/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPLiveSummaryDao.h"
#import "GLPLiveSummaryDaoParser.h"
#import "GLPLiveSummary.h"
#import "FMResultSet.h"
#import "DatabaseManager.h"

@implementation GLPLiveSummaryDao

+ (GLPLiveSummary *)findCurrentLiveSummary
{
    __block GLPLiveSummary *liveSummary = nil;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {

        liveSummary = [GLPLiveSummaryDao findCurrentLiveSummaryWithDb:db];
        
    }];
    
    return liveSummary;
}

+ (GLPLiveSummary *)findCurrentLiveSummaryWithDb:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from live_summary"];
    
    return [GLPLiveSummaryDaoParser createFromResultSet:resultSet];
}

/**
 Saves or updates live summary.
 
 @param liveSummary the new live summary.
 
 */
+ (BOOL)saveLiveSummary:(GLPLiveSummary *)liveSummary
{
    __block BOOL success = NO;

    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {

        [db executeUpdateWithFormat:@"delete from live_summary"];
        success = [GLPLiveSummaryDao saveLiveSummary:liveSummary db:db];
        
    }];
    
    return success;
}

+ (BOOL)saveLiveSummary:(GLPLiveSummary *)liveSummary db:(FMDatabase *)db
{
    BOOL success = NO;

    for(NSNumber *categoryKey in liveSummary.byCategoryPosts)
    {
        NSInteger categoryPostCount = [[liveSummary.byCategoryPosts objectForKey:categoryKey] integerValue];
        success = [GLPLiveSummaryDao saveCategoryKey:[categoryKey integerValue] withCategoryPostsCount:categoryPostCount db:db];
    }
    
    return success;
}

+ (BOOL)saveCategoryKey:(NSInteger)categoryKey withCategoryPostsCount:(NSInteger)categoryPostsCount db:(FMDatabase *)db
{
    BOOL success = NO;
    
    success = [db executeUpdateWithFormat:@"insert into live_summary (category_remote_key, category_posts_count) values(%d,%d)", categoryKey, categoryPostsCount];
    
    return success;
}

@end