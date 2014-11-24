//
//  GLPApprovalManager.h
//  Gleepost
//
//  Created by Silouanos on 24/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPApproveLevel.h"

@interface GLPApprovalManager : NSObject

+ (GLPApprovalManager *)sharedInstance;
- (void)reloadApprovalLevel;
- (ApproveLevel)currentApprovalLevel;

@end
