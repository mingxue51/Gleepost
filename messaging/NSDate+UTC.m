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
    NSTimeZone *timezone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = timezone;
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *utcDateString = [formatter stringFromDate:localDate];
    NSDate *utcDate = [formatter dateFromString:utcDateString];

    return utcDate;
}

@end
