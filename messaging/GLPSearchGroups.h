//
//  GLPSearchGroups.h
//  Gleepost
//
//  Created by Silouanos on 28/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPSearchGroups : NSObject

- (void)searchGroupsWithQuery:(NSString *)query;
- (void)loadGroupWithUserRemoteKey:(NSInteger)userRemoteKey;

@end
