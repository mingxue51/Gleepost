//
//  GLPPostOperationManager.h
//  Gleepost
//
//  Created by Silouanos on 20/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"
#import "GLPComment.h"

@interface GLPPostOperationManager : NSObject
+ (GLPPostOperationManager *)sharedInstance;
-(void)uploadImage:(UIImage*)image withTimestamp:(NSDate*)timestamp;
-(void)setPost:(GLPPost*)post withTimestamp:(NSDate*)timestamp;
-(void)stopTimer;
-(void)uploadComment:(GLPComment*)comment;
@end
