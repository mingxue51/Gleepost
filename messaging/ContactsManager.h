//
//  ContactsManager.h
//  Gleepost
//
//  Created by Σιλουανός on 31/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//
//  Class responsible of managing groups' posts' data in Campus Wall.
//

#import <Foundation/Foundation.h>
#import "GLPContactDao.h"

@interface ContactsManager : NSObject
@property (strong, nonatomic) NSArray* contacts;


+(ContactsManager*)sharedInstance;
-(BOOL)isUserContactWithId:(int)remoteKey;
-(BOOL)isContactWithIdRequested:(int)remoteKey;
-(BOOL)isContactWithIdRequestedYou:(int)remoteKey;
-(GLPContact*)contactWithRemoteKey:(int)remoteKey;
-(void)saveNewContact:(GLPContact*)contact db:(FMDatabase *)db;
-(void)loadContactsFromDatabase;
-(BOOL)navigateToUnlockedProfileWithSelectedUserId:(int)selectedId;
-(void)contactWithRemoteKeyAccepted:(int)remoteKey;
-(void)loadContactsWithLocalCallback:(void (^)(NSArray *contacts))localCallback remoteCallback:(void (^)(BOOL success, NSArray *contacts))remoteCallback;
-(void)loadUserWithRemoteKey:(int)remoteKey localCallback:(void (^) (BOOL exist, GLPUser *user))localCallback remoteCallback:(void (^) (BOOL success, GLPUser *user))remoteCallback;
-(void)acceptContact:(int)remoteKey callbackBlock:(void (^)(BOOL success))callbackBlock;
-(void)refreshContacts;
-(NSDictionary*)findConfirmedContacts;
-(NSDictionary*)findConfirmedContactsTemp:(NSArray*)contactsFromServer;
-(UIImage*)contactImageWithRemoteKey:(int)remoteKey;
-(BOOL)isLoggedInUser:(GLPUser *)user;


@end
