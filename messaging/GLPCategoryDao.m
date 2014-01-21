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

@implementation GLPCategoryDao

+(GLPCategory*)findByRemoteKey:(NSInteger)remoteKey
{
    __block GLPCategory *category = nil;
    
    [DatabaseManager run:^(FMDatabase *db) {
        category = [GLPCategoryDao findByRemoteKey:remoteKey db:db];
    }];
    
    return category;
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

+(void)saveCategoryIfNotExist:(GLPCategory*)category db:(FMDatabase *)db
{
    
    NSArray *categoriesForPost = [GLPCategoryDao findByPostRemoteKey:category.postRemoteKey db:db];
    
    if(!categoriesForPost)
    {
        [db executeUpdateWithFormat:@"insert into categories (remoteKey, tag, name, post_remote_key) values(%d, %@, %@, %d)",
         category.remoteKey,
         category.tag,
         category.name,
         category.postRemoteKey];
        
        category.key = [db lastInsertRowId];
    }
    else
    {
        //Don't insert anything.
    }
    

}

@end
