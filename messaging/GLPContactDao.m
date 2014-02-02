//
//  GLPContactDao.m
//  Gleepost
//
//  Created by Σιλουανός on 31/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPContactDao.h"
#import "DatabaseManager.h"
#import "GLPContactDaoParser.h"
#import "GLPUserDao.h"

@implementation GLPContactDao

+ (GLPContact *)findByRemoteKey:(NSInteger)remoteKey
{
    __block GLPContact *contact = nil;
    
    [DatabaseManager run:^(FMDatabase *db) {
        contact = [GLPContactDao findByRemoteKey:remoteKey db:db];
    }];
    
    return contact;
}


+ (GLPContact *)findByRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from contacts where remoteKey=%d limit 1", remoteKey];
    
    GLPContact *contact = nil;
    
    if([resultSet next]) {
        contact = [GLPContactDaoParser createContactFromResultSet:resultSet];
    }
    
    return contact;
}

+(NSArray*)loadContactsFromDb:(FMDatabase*)db
{
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from contacts"];
    
    while ([resultSet next])
    {
        GLPContact *currentContact = [GLPContactDaoParser createContactFromResultSet:resultSet];
        
        //Load user's details for current contact.
        currentContact.user = [GLPUserDao findByRemoteKey:currentContact.remoteKey db:db];
        
        [contacts addObject: currentContact];
        
    }
    
    return contacts;

}

+(NSArray*)loadContacts
{
    __block NSArray *contacts = nil;
    
    [DatabaseManager run:^(FMDatabase *db) {
        contacts = [GLPContactDao loadContactsFromDb:db];
    }];
    
    return contacts;
}

+ (void)save:(GLPContact *)entity inDb:(FMDatabase *)db
{
    [db executeUpdateWithFormat:@"insert into contacts(remoteKey, you_confirmed, they_confirmed, name) values(%d, %d, %d, %@)", entity.remoteKey, entity.youConfirmed, entity.theyConfirmed, entity.user.name];
}


/**
 
 [db executeUpdateWithFormat:@"update notifications set seen=%d where key=%d",
 entity.seen,
 entity.key];

 */

+(void)setContactAsRegularContactWithRemoteKey:(int)remoteKey
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        BOOL s = [db executeUpdateWithFormat:@"update contacts set they_confirmed=1 where remoteKey=%d",remoteKey];
        NSLog(@"Contact became regular. %d",s);
        
    }];
}

+(void)deleteTable
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdateWithFormat:@"delete from contacts"];
    }];
}

+(void)deleteTableWithDb:(FMDatabase*)db
{
    [db executeUpdateWithFormat:@"delete from contacts"];
}

@end
