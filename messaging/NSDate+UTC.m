//
//  NSDate+UTC.m
//  Gleepost
//
//  Created by Lukas on 10/16/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "NSDate+UTC.h"

@implementation NSDate (UTC)

+ (NSDate *)dateInUTC
{
    NSDate *localDate = [NSDate date];
    NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSInteger seconds = [tz secondsFromGMTForDate: localDate];
    return [NSDate dateWithTimeInterval: seconds sinceDate: localDate];
}

@end
