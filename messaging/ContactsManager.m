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
    [self loadContacts];
    
    return self;
}

-(void)saveNewContact:(GLPContact*)contact
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPContactDao save:contact inDb:db];
    }];
}

-(void)refreshFromDatabase
{
    [self loadContacts];
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

-(void)loadContacts
{
    self.contacts = [GLPContactDao loadContacts];
    
}

/**
 Return YES if the user with the remoteKey is contact with the current user.
 
 @param remoteKey user remote key.
 
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

/**
 If YES navigate to real profile, if no to private profile.
 */
-(BOOL)navigateToUnlockedProfileWithSelectedUserId:(int)selectedId
{
    [self refreshContacts];

    [self refreshFromDatabase];
    
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
            NSLog(@"PrivateProfileViewController : User already requested by you.");
            //            UIImage *img = [UIImage imageNamed:@"invitesent"];
            //            [self.addUserButton setImage:img forState:UIControlStateNormal];
            //            [self.addUserButton setEnabled:NO];
            //
            //For now just navigate to the unlocked profile.
            
            return NO;
            
        }
        else
        {
            //If not show the private profile view as is.
            NSLog(@"PrivateProfileViewController : Private profile as is.");
            
            return NO;
        }
    }
}

//-(void)deleteTable
//{
//    [GLPContactDao deleteTable];
//}

@end
