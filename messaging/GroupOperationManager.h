//
//  GroupOperationManager.h
//  Gleepost
//
//  Created by Σιλουανός on 6/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPGroup.h"
#import "GLPOperationManager.h"

@interface GroupOperationManager : GLPOperationManager

+ (GroupOperationManager *)sharedInstance;
-(void)setGroup:(GLPGroup *)group withTimestamp:(NSDate *)timestamp;

//-(void)stopTimer;
//-(void)uploadImage:(UIImage *)image withTimestamp:(NSDate *)timestamp;

@end
