//
//  RemoteMessage+Additions.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "RemoteMessage+Additions.h"
#import "RemoteUser.h"

@implementation RemoteMessage (Additions)

- (BOOL)followsPreviousMessage:(RemoteMessage *)message
{
    if(![message.author.remoteKey isEqualToNumber:self.author.remoteKey]) {
        return NO;
    }
    
    //    NSTimeInterval interval = [self.date timeIntervalSinceDate:message.date];
    //    NSLog(@"time interval %f", interval);
    //    if(interval / 60 > 15) {
    //        return NO;
    //    }
    
    return YES;
}

@end
