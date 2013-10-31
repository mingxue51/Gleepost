//
//  ContactsManager.h
//  Gleepost
//
//  Created by Σιλουανός on 31/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPContactDao.h"

@interface ContactsManager : NSObject
@property (strong, nonatomic) NSArray* contacts;


+(ContactsManager*)sharedInstance;
-(BOOL)isUserContactWithId:(int)remoteKey;
-(BOOL)isContactWithIdRequested:(int)remoteKey;
-(GLPContact*)contactWithRemoteKey:(int)remoteKey;

@end
