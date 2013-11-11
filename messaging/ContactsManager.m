//
//  ContactsManager.m
//  Gleepost
//
//  Created by Σιλουανός on 31/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ContactsManager.h"

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
    
    //Load contacts from database.
    [self loadContacts];
    
    return self;
}

-(void)refreshContacts
{
    [self loadContacts];
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
    
    return (contact.youConfirmed || contact.theyConfirmed);
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

@end
