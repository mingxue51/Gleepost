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
    if(!self) {
        return nil;
    }
    
    
    [self refreshContacts];
    
    //Load contacts from database.
    [self loadContactsFromDatabase];
    
    return self;
}

-(void)saveNewContact:(GLPContact*)contact
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPContactDao save:contact inDb:db];
    }];
}

-(void)refreshContacts
{
    //Load contacts from server and update database.
    
    [[WebClient sharedInstance ] getContactsWithCallbackBlock:^(BOOL success, NSArray *contacts) {
        
        if(success)
        {
            //Store contacts into an array.
            NSLog(@"Contacts loaded successfully.");
            
            self.contacts = contacts;

            [GLPContactDao deleteTable];
            
            [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
                for(GLPContact *c in contacts) {
                    [GLPContactDao save:c inDb:db];
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
    
    NSLog(@"You confirmed: %d",contact.youConfirmed);
    
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


+ (void)loadContactsWithLocalCallback:(void (^)(NSArray *contacts))localCallback remoteCallback:(void (^)(BOOL success, NSArray *contacts))remoteCallback
{
    NSArray *localEntities = [GLPContactDao loadContacts];
    localCallback(localEntities);
    NSLog(@"Load local contacts %d", localEntities.count);
    
    
    [[WebClient sharedInstance ] getContactsWithCallbackBlock:^(BOOL success, NSArray *serverContacts) {
        
        
        if(!success) {
            remoteCallback(NO, nil);
            return;
        }
        

            //Store contacts into an array.
            NSLog(@"Contacts loaded successfully.");
            
    
        
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
        NSLog(@"PrivateProfileViewController : Unlock Profile.");
        
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
