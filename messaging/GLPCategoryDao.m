//
//  GLPCategoryDao.m
//  Gleepost
//
//  Created by Silouanos on 21/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCategoryDao.h"
#import "GLPCategoryDaoParser.h"
#import "DatabaseManager.h"
#import "CategoryManager.h"

@implementation GLPCategoryDao

+(GLPCategory*)findByRemoteKey:(NSInteger)remoteKey
{
    __block GLPCategory *category = nil;
    
    [DatabaseManager run:^(FMDatabase *db) {
        category = [GLPCategoryDao findByRemoteKey:remoteKey db:db];
    }];
    
    return category;
}

/**
 This method finds all the posts with the global selected category
 is selected by the user.
 
 @return all the posts remote keys assigned with the selected category.
 //Not used for now.
 */
+ (NSArray *)findPostsWithSelectedCategoryWithDb:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from categories where tag=%@", [[CategoryManager sharedInstance] selectedCategory].tag];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next])
    {
        GLPCategory *c = [GLPCategoryDaoParser createFromResultSet:resultSet inDb:db];
        DDLogDebug(@"Post from categories: %d", c.postRemoteKey);
        [result addObject:@(c.postRemoteKey)];
    }
    
    return result;
}

+ (GLPCategory *)findByRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from categories where remoteKey=%d limit 1", remoteKey];
    
    GLPCategory *category = nil;
    
    if([resultSet next])
    {
        category = [GLPCategoryDaoParser createFromResultSet:resultSet inDb:db];
    }
    
    return category;
}

+(NSArray*)findByPostRemoteKey:(NSInteger)postRemoteKey db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from categories where post_remote_key=%d", postRemoteKey];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next])
    {
        GLPCategory *c = [GLPCategoryDaoParser createFromResultSet:resultSet inDb:db];
        [result addObject:c];
    }
    
    return result;
}

+(NSArray*)findByPostRemoteKey:(NSInteger)postRemoteKey andCategoryRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from categories where post_remote_key=%d AND remoteKey=%d", postRemoteKey, remoteKey];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next])
    {
        GLPCategory *c = [GLPCategoryDaoParser createFromResultSet:resultSet inDb:db];
        [result addObject:c];
    }
    
    return result;
}

+(void)saveCategoryIfNotExist:(GLPCategory*)category db:(FMDatabase *)db
{
    
    NSArray *categoriesForPost = [GLPCategoryDao findByPostRemoteKey:category.postRemoteKey andCategoryRemoteKey:category.remoteKey db:db];
    
    
    if(categoriesForPost.count == 0 || !categoriesForPost)
    {
        [db executeUpdateWithFormat:@"insert into categories (remoteKey, tag, name, post_remote_key) values(%d, %@, %@, %d)",
         category.remoteKey,
         category.tag,
         category.name,
         category.postRemoteKey];
        
        category.key = [db lastInsertRowId];

    }
    

}

@end
