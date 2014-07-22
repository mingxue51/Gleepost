//
//  GLPServerPathManager.h
//  Gleepost
//
//  Created by Σιλουανός on 21/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPServerPathManager : NSObject

- (void)switchServerMode;
- (NSString *)serverPath;
- (NSString *)serverMode;

@end
