//
//  NSNumber+Enums.m
//  Gleepost
//
//  Created by Lukas on 10/13/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "NSNumber+Enums.h"

@implementation NSNumber (Enums)

+ (NSNumber *)numberWithSendStatus:(SendStatus)sendStatus
{
    return [NSNumber numberWithInt:(int)sendStatus];
}

- (SendStatus)sendStatusValue
{
    int intValue = [self intValue];
    NSAssert(intValue >= 1 && intValue <= 3, @"unsupported send status");
    return (SendStatus)intValue;
}

@end
