//
//  GLPLongPollManager.h
//  Gleepost
//
//  Created by Lukas on 10/21/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPBackgroundRequestsManager : NSObject

+ (GLPBackgroundRequestsManager *)sharedInstance;

- (void)startAll;
- (void)stopAll;

@end
