//
//  GLPCommentManager.h
//  Gleepost
//
//  Created by Silouanos on 25/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPCommentDao.h"

@interface GLPCommentManager : NSObject

+ (void)loadCommentsWithLocalCallback:(void (^)(NSArray *comments))localCallback remoteCallback:(void (^)(BOOL success, NSArray *comments))remoteCallback withPost:(GLPPost *)post;

+ (void)loadCommentsWithPost:(GLPPost *)post localCallback:(void (^)(NSArray *))localCallback remoteCallback:(void (^)(BOOL, NSArray *))remoteCallback;

@end
