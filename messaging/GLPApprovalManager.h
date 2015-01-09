//
//  GLPApprovalManager.h
//  Gleepost
//
//  Created by Silouanos on 24/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This manager has the responsibility of managing the approval level status.

#import <Foundation/Foundation.h>
#import "GLPApproveLevel.h"

@class GLPPost;

@interface GLPApprovalManager : NSObject

+ (GLPApprovalManager *)sharedInstance;
- (void)reloadApprovalLevel;
- (ApproveLevel)currentApprovalLevel;
- (BOOL)shouldPostBeVisible:(GLPPost *)post;


@end
