//
//  GLPLiveSummaryDaoParser.m
//  Gleepost
//
//  Created by Silouanos on 25/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPLiveSummaryDaoParser.h"
#import "GLPLiveSummary.h"
#import "FMDatabase.h"

@implementation GLPLiveSummaryDaoParser

+ (GLPLiveSummary *)parseResultSet:(FMResultSet *)resultSet
{
    NSMutableDictionary *postsCountByCategory = [[NSMutableDictionary alloc] init];
    
    while ([resultSet next])
    {
        NSInteger categoryKey = [resultSet intForColumn:@"category_remote_key"];
        NSInteger categoryPostsCount = [resultSet intForColumn:@"category_posts_count"];
        [postsCountByCategory setObject:@(categoryPostsCount) forKey:@(categoryKey)];
    }
    
    return [[GLPLiveSummary alloc] initWithCategoryData:postsCountByCategory.mutableCopy];
}

+ (GLPLiveSummary *)createFromResultSet:(FMResultSet *)resultSet
{
    return [GLPLiveSummaryDaoParser parseResultSet:resultSet];
}



@end
