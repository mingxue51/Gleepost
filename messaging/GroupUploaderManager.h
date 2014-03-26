//
//  GroupUploaderManager.h
//  Gleepost
//
//  Created by Σιλουανός on 6/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPGroup.h"

@interface GroupUploaderManager : NSObject

-(void)addGroup:(GLPGroup*)group withTimestamp:(NSDate*)timestamp;
-(void)uploadGroupWithTimestamp:(NSDate*)timestamp andImageUrl:(NSString*)url;
-(NSDictionary *)pendingGroups;
-(void)changeGroupImageWithImage:(UIImage *)image withGroup:(GLPGroup *)group;
-(UIImage *)pendingGroupImageWithRemoteKey:(int)remoteKey;


@end
