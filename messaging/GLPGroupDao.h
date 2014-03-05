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

-(void)save:(GLPGroup *)group;
-(void)remove:(GLPGroup *)group;
-(NSArray *)findGroups;
+(void)updateGroupSendingData:(GLPGroup *)entity;


@end
