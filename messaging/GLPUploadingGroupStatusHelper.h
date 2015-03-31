//
//  GLPUploadingGroupStatusHelper.h
//  Gleepost
//
//  Created by Silouanos on 31/03/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPUploadingGroupStatusHelper : NSObject

- (void)unregisterGroup;
- (void)registerGroup;
- (CGFloat)uploadingGroupProgress;

@end
