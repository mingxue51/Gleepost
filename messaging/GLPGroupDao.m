//
//  GLPGroupDao.m
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPGroupDao.h"
#import "DatabaseManager.h"
#import "GLPGroupDaoParser.h"


@implementation GLPGroupDao


+ (NSArray *)findGroupsdb:(FMDatabase *)db
{
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    //TODO: Do that descending.
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from groups"];
    
    while ([resultSet next])
    {
        GLPGroup *currentGroup = [GLPGroupDaoParser createFromResultSet:resultSet inDb:db];
    
        [groups addObject: currentGroup];
        
    }
    
    return groups;
}

-(NSArray *)findGroups
{
    __block NSArray *groups = [[NSMutableArray alloc] init];
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        groups = [GLPGroupDao findGroupsdb:db];
        
    }];
    
    return groups;
}

-(void)save:(GLPGroup *)group
{
    
}

-(void)remove:(GLPGroup *)group
{
    
}



+(void)updateGroupSendingData:(GLPGroup *)entity
{
    
}

@end
