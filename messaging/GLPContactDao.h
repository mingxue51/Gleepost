//
//  GLPContactDao.h
//  Gleepost
//
//  Created by Σιλουανός on 31/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPContact.h"
#import "FMDatabase.h"

@interface GLPContactDao : NSObject

+ (GLPContact *)findByRemoteKey:(NSInteger)remoteKey;
+ (GLPContact *)findByRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db;
+(NSArray*)loadContacts;
+ (void)save:(GLPContact *)entity;

@end
