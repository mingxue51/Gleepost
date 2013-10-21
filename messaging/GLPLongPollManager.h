//
//  GLPLongPollManager.h
//  Gleepost
//
//  Created by Lukas on 10/21/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPLongPollManager : NSObject

+ (GLPLongPollManager *)sharedInstance;
- (void)startLongPoll;
- (void)stopLongPoll;

@end
