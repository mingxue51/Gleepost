//
//  GLPCategoryDao.h
//  Gleepost
//
//  Created by Silouanos on 21/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "GLPCategory.h"

@interface GLPCategoryDao : NSObject

+(GLPCategory*)findByRemoteKey:(NSInteger)remoteKey;
+(NSArray*)findByPostRemoteKey:(NSInteger)postRemoteKey db:(FMDatabase *)db;
+(void)saveCategoryIfNotExist:(GLPCategory*)category db:(FMDatabase *)db;

@end
