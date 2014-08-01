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
#import "GLPProfileLoader.h"
#import "GLPUser.h"
#import "SessionManager.h"

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
        [GLPUserDao saveIfNotExist:contact.user db:db];
    }
    

}

/**
 Load contacts from the server and save them to the Contacts array and to the database.
 */
-(void)refreshContacts
{
    [self loadContactsWithLocalCallback:^(NSArray *contacts) {
        
        //Store contacts into an array.
        self.contacts = contacts;
        
        DDLogDebug(@"Local contacts: %@", contacts);
        
    } remoteCallback:^(BOOL success, NSArray *contacts) {
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
        }
        
    }];
    
    //Load contacts from server and update database.
//    [[WebClient sharedInstance ] getContactsWithCallback:^(BOOL success, NSArray *contacts) {
//        
//        if(success)
//        {
//            //Store contacts into an array.
//            self.contacts = contacts;
//            
//            //Load contacts' images.
//            [[GLPProfileLoader sharedInstance] loadContactsImages:contacts];
//            
//            
//            [GLPContactDao deleteTable];
//            
//            [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//                
//                for(GLPContact *c in contacts) {
//                    //[GLPContactDao save:c inDb:db];
//                    [self saveNewContact:c db:db];
//                }
//            }];
//            
//        }
//        else
//        {
//            [WebClientHelper showStandardError];
//        }
//        
//        
//    }];
}

-(void)loadContactsFromDatabase
{
    //TODO: Problem: Not loading users. Users' details seems are not saving correctly.
    self.contacts = [GLPContactDao loadContacts];
    
}

#pragma mark - Accessors

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
            if(contact.user.name)
            {
                //TODO: Bug here. User sometimes is nil.
                [confirmedContacts addObject:contact];
                [confirmedContactsNames addObject:contact.user.name];
            }
            else
            {
                return nil;
            }

        }
    }
    
    dictonaryContacts = [[NSMutableDictionary alloc] initWithObjects:@[confirmedContacts, confirmedContactsNames] forKeys: @[@"Contacts",@"ContactsUserNames"]];
    
    
    return dictonaryContacts;
}

-(NSDictionary*)findConfirmedContactsTemp:(NSArray*)contactsFromServer
{
    NSMutableArray *confirmedContacts = [[NSMutableArray alloc] init];
    NSMutableArray *confirmedContactsNames = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *dictonaryContacts = nil;
    //Created for test purposes.
    for(GLPContact* contact in contactsFromServer)
    {
        if(contact.youConfirmed && contact.theyConfirmed)
        {
            //TODO: Bug here. User is nil.
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
    
    DDLogDebug(@"Contact requested: %@ : %d", contact.user, contact.youConfirmed);
    
    return contact.youConfirmed;
}

-(BOOL)isContactWithIdRequestedYou:(int)remoteKey
{
    GLPContact* contact = [self contactWithRemoteKey:remoteKey];
    
    return contact.theyConfirmed;
}

-(BOOL)isLoggedInUser:(GLPUser *)user
{
    return ([SessionManager sharedInstance].user.remoteKey == user.remoteKey);
}

-(GLPContact*)contactWithRemoteKey:(int)remoteKey
{
    for(GLPContact* contact in self.contacts)
    {
        if(contact.remoteKey == remoteKey)
        {
            DDLogDebug(@"Contact exist: %@", contact.user);
            
            return contact;
        }
    }
    
    return nil;
}

-(UIImage*)contactImageWithRemoteKey:(int)remoteKey
{
    return [[GLPProfileLoader sharedInstance]contactImageWithRemoteKey:remoteKey];
}

-(void)contactWithRemoteKeyAccepted:(int)remoteKey
{
    [GLPContactDao setContactAsRegularContactWithRemoteKey:remoteKey];
}


/**
 Callback accepts contact with remote key.
 If the contact is in local database then update it and reload contacts from database,
 otherwise refresh contacts.
 
 @param remoteKey contact's remote key
 
 */
-(void)acceptContact:(int)remoteKey callbackBlock:(void (^)(BOOL success))callbackBlock
{
    GLPContact* contact = [self contactWithRemoteKey:remoteKey];
    
    [[WebClient sharedInstance]acceptContact:remoteKey callbackBlock:^(BOOL success) {

        if(success)
        {
            if(contact)
            {
                [self contactWithRemoteKeyAccepted:remoteKey];
                [self loadContactsFromDatabase];
                
                DDLogDebug(@"Contact exist in database: %@", contact);
            }
            else
            {
                DDLogDebug(@"Contact not exist in database: %@", contact);

                [self refreshContacts];
            }

            callbackBlock(success);
        }
        else
        {
            callbackBlock(NO);
        }
        
    }];
}


- (void)loadContactsWithLocalCallback:(void (^)(NSArray *contacts))localCallback remoteCallback:(void (^)(BOOL success, NSArray *contacts))remoteCallback
{    
    NSArray *localEntities = [GLPContactDao loadContacts];
    localCallback(localEntities);
    
    
    [[WebClient sharedInstance ] getContactsWithCallback:^(BOOL success, NSArray *serverContacts) {
        
        if(!success) {
            remoteCallback(NO, nil);
            return;
        }
        
        //Refresh contacts' images in case a contact has new profile image.
        [[GLPProfileLoader sharedInstance] refreshContactsImages:serverContacts];

            self.contacts = serverContacts;

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

-(void)loadUserWithRemoteKey:(int)remoteKey localCallback:(void (^) (BOOL exist, GLPUser *user))localCallback remoteCallback:(void (^) (BOOL success, GLPUser *user))remoteCallback
{
    //Load user from local database.
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        GLPUser *currentUser = [GLPUserDao findByRemoteKey:remoteKey db:db];
        
        if(currentUser)
        {
            localCallback(YES,currentUser);
        }
        else
        {
            localCallback(NO,currentUser);
        }
        

    }];
    
    [[WebClient sharedInstance] getUserWithKey:remoteKey callbackBlock:^(BOOL success, GLPUser *user) {
        
        if(success)
        {
            //Update the user in the local database.
            [GLPUserDao update:user];
            
            remoteCallback(success, user);
            
        }
        else
        {
            remoteCallback(success, user);
        }
        
    }];
}

//TODO: This will be used for the GleepostSD app.

///**
// If YES navigate to real profile, if no to private profile.
// */
//-(BOOL)navigateToUnlockedProfileWithSelectedUserId:(int)selectedId
//{
//    //[self refreshContacts];
//
//    [self loadContactsFromDatabase];
//    
//    //Check if the user is already in contacts.
//    //If yes show the regular profie view (unlocked).
//    if([[ContactsManager sharedInstance] isUserContactWithId:selectedId])
//    {        
//        return YES;
//    }
//    else
//    {
//        //If no, check in database if the user is already requested.
//        
//        //If yes change the button of add user to user already requested.
//        
//        if([[ContactsManager sharedInstance] isContactWithIdRequested:selectedId])
//        {
//            
//            return NO;
//            
//        }
//        else
//        {
//            return NO;
//        }
//    }
//}

- (UserRelationship)userRelationshipWithId:(NSInteger)userId
{
    [self loadContactsFromDatabase];
    
    if([SessionManager sharedInstance].user.remoteKey == userId)
    {
        return kCurrentUser;
    }
    else
    {
        return kOtherUser;
    }
}

//-(void)deleteTable
//{
//    [GLPContactDao deleteTable];
//}

@end
