//
//  DateFormatterHelper.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "DateFormatterHelper.h"

@implementation DateFormatterHelper

+ (NSDateFormatter *)createDefaultDateFormatter
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    f.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return f;
}

// date formatter that matches the API format
+ (NSDateFormatter *)createRemoteDateFormatter
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

    f.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    return f;
}

+ (NSDateFormatter *)createRemoteDateFormatterWithNanoSeconds
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

    f.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSSZ";
    return f;
}

+ (NSDateFormatter *)createTimeDateFormatter
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

    f.dateFormat = @"HH:mm";
    return f;
}

+ (NSDateFormatter *)createMessageDateFormatter {
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    f.dateFormat = @"EEEE hh:mm a";
    return f;

}

+(NSString *)dateUnixFormat:(NSDate *)date
{
    return [NSString stringWithFormat:@"%.0f", [date timeIntervalSince1970]];
}

+(NSDate *)generateDateWithDay:(int)day month:(int)month year:(int)year hour:(int)hour andMinutes:(int)minutes
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    
    
    [comp setDay:day];
    [comp setMonth:month];
    [comp setHour:hour];
    [comp setMinute:minutes];
    [comp setYear:year];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comp];
    
    return date;
}

+(NSDate *)generateDateAfterDays:(int)days
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    
    
    [comp setDay:comp.day+days];
//    [comp setMonth:comp.month];
    [comp setHour:comp.hour];
    [comp setMinute:comp.minute];
//    [comp setYear:year];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comp];
    
    return date;
}

@end
