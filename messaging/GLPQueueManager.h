//
//  GLPQueueManager.h
//  Gleepost
//
//  Created by Silouanos on 18/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"

@interface GLPQueueManager : NSObject

+ (GLPQueueManager *)sharedInstance;

-(void)uploadPost:(GLPPost*)post withId:(int)key;
-(void)uploadImage:(UIImage*)image withId:(int)key;

@end
