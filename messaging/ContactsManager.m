 //
//  ContactsManager.m
//  Gleepost
//
//  Created by Σιλουανός on 31/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ContactsManager.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "DatabaseManager.h"
#import "GLPUserDao.h"

@implementation ContactsManager

static ContactsManager *instance = nil;


+(ContactsManager*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ContactsManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        //[self refreshContacts];
    }
    
    //Load contacts from database.
    //[self loadContactsFromDatabase];
    
    return self;
}

-(void)saveNewContact:(GLPContact*)contact db:(FMDatabase*) db
{
    if(db == nil)
    {
        
        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
            [GLPContactDao save:contact inDb:db];
            [GLPUserDao saveIfNotExist:contact.user db:db];
        }];
    
    }
    else
    {
        [GLPContactDao save:contact inDb:db];
        NSLog(@"New Contact User id: %d",[GLPUserDao saveIfNotExist:contact.user db:db]);
    }
    

}

/**
 Load contacts from the server and save them to the Contacts array and to the database.
 */
-(void)refreshContacts
{
    //Load contacts from server and update database.
    
    [[WebClient sharedInstance ] getContactsWithCallback:^(BOOL success, NSArray *contacts) {
        
        if(success)
        {
            //Store contacts into an array.
            self.contacts = contacts;

            [GLPContactDao deleteTable];
            
            [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
                
                for(GLPContact *c in contacts) {
                    //[GLPContactDao save:c inDb:db];
                    [self saveNewContact:c db:db];
                }
            }];
            
        }
        else
        {
            [WebClientHelper showStandardError];
        }
        
        
    }];
}

-(void)loadContactsFromDatabase
{
    self.contacts = [GLPContactDao loadContacts];
    
}

/**
 Finds the real contacts (accepted from both sides) and return them.
 
 @return dictionary contains an array with confirmed contacts and an array with just users' names.
 
 */
-(NSDictionary*)findConfirmedContacts
{
    NSMutableArray *confirmedContacts = [[NSMutableArray alloc] init];
    NSMutableArray *confirmedContactsNames = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *dictonaryContacts = nil;
    //Created for test purposes.
    for(GLPContact* contact in self.contacts)
    {
        if(contact.youConfirmed && contact.theyConfirmed)
        {
            //TODO: Bug here. User name is nil.
            [confirmedContacts addObject:contact];
            [confirmedContactsNames addObject:contact.user.name];
        }
    }
    
    dictonaryContacts = [[NSMutableDictionary alloc] initWithObjects:@[confirmedContacts, confirmedContactsNames] forKeys: @[@"Contacts",@"ContactsUserNames"]];
    
    
    return dictonaryContacts;
}

/**
 Return YES if the user with the remoteKey is contact with the current user.
 
 @param remoteKey user remote key.χ
 
 @return YES if the user is contact, otherwise NO.
 
 */
-(BOOL)isUserContactWithId:(int)remoteKey
{
    for(GLPContact* contact in self.contacts)
    {
        if(contact.remoteKey == remoteKey)
        {
            if(contact.theyConfirmed == YES && contact.youConfirmed == YES)
            {
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL)isContactWithIdRequested:(int)remoteKey
{
    GLPContact* contact = [self contactWithRemoteKey:remoteKey];
    
    
    return contact.youConfirmed;
}

-(BOOL)isContactWithIdRequestedYou:(int)remoteKey
{
    GLPContact* contact = [self contactWithRemoteKey:remoteKey];
    
    return contact.theyConfirmed;
}

-(GLPContact*)contactWithRemoteKey:(int)remoteKey
{
    for(GLPContact* contact in self.contacts)
    {
        if(contact.remoteKey == remoteKey)
        {
            return contact;
        }
    }
    
    return nil;
}

-(void)contactWithRemoteKeyAccepted:(int)remoteKey
{
    [GLPContactDao setContactAsRegularContactWithRemoteKey:remoteKey];
}

-(void)acceptContact:(int)remoteKey callbackBlock:(void (^)(BOOL success))callbackBlock
{
    [[WebClient sharedInstance]acceptContact:remoteKey callbackBlock:^(BOOL success) {

        if(success)
        {
            [self contactWithRemoteKeyAccepted:remoteKey];
            [self loadContactsFromDatabase];
            callbackBlock(success);
        }
        else
        {
            callbackBlock(NO);
        }
        
    }];
}


+ (void)loadContactsWithLocalCallback:(void (^)(NSArray *contacts))localCallback remoteCallback:(void (^)(BOOL success, NSArray *contacts))remoteCallback
{
    NSArray *localEntities = [GLPContactDao loadContacts];
    localCallback(localEntities);
    
    
    [[WebClient sharedInstance ] getContactsWithCallback:^(BOOL success, NSArray *serverContacts) {
        
        
        if(!success) {
            remoteCallback(NO, nil);
            return;
        }
        

            //Store contacts into an array.
        
            [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
                
                [GLPContactDao deleteTableWithDb:db];

                for(GLPContact *c in serverContacts) {
                    [GLPContactDao save:c inDb:db];
                }
            }];
        

        remoteCallback(YES, serverContacts);

        
    }];
}


/**
 If YES navigate to real profile, if no to private profile.
 */
-(BOOL)navigateToUnlockedProfileWithSelectedUserId:(int)selectedId
{
    //[self refreshContacts];

    [self loadContactsFromDatabase];
    
    //Check if the user is already in contacts.
    //If yes show the regular profie view (unlocked).
    if([[ContactsManager sharedInstance] isUserContactWithId:selectedId])
    {        
        return YES;
    }
    else
    {
        //If no, check in database if the user is already requested.
        
        //If yes change the button of add user to user already requested.
        
        if([[ContactsManager sharedInstance] isContactWithIdRequested:selectedId])
        {
            
            return NO;
            
        }
        else
        {
            return NO;
        }
    }
}

//-(void)deleteTable
//{
//    [GLPContactDao deleteTable];
//}

@end
