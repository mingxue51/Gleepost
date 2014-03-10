//
//  GLPGroupDao.h
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPGroup.h"

@interface GLPGroupDao : NSObject


+(void)saveGroups:(NSArray *)groups;
+(void)save:(GLPGroup *)group;
+(void)remove:(GLPGroup *)group;
+(NSArray *)findGroups;
+(NSArray *)findRemoteGroups;
+(void)updateGroupSendingData:(GLPGroup *)entity;
+(void)updateGroup:(GLPGroup *)entity;


@end
