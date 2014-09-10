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

+ (NSString *)generateStringDateForFSFormat
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    
    NSDate *cDate = [NSDate date];
    
    NSString *currentDateStr = [dateFormat stringFromDate:cDate];
    
    return currentDateStr;
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

+(NSDate *)generateTodayDateWhenItStarts
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    
    
    [comp setDay:comp.day];
    //    [comp setMonth:comp.month];
    [comp setHour:0];
    [comp setMinute:0];
    //    [comp setYear:year];
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

+(NSDate *)generateDateAfterHours:(int)hours
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    
    
    [comp setDay:comp.day];
    //    [comp setMonth:comp.month];
    [comp setHour:comp.hour+hours];
    [comp setMinute:comp.minute];
    //    [comp setYear:year];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comp];
    
    return date;
}

+(NSDate *)generateDateWithLastMinutePlusDates:(int)dates
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    
    
    [comp setDay:comp.day+dates];
    //    [comp setMonth:comp.month];
    [comp setHour:23];
    [comp setMinute:59];
    //    [comp setYear:year];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comp];
    
    return date;
}

+(NSArray *)generateTheNextDayStartAndEnd
{
    
    NSDate *dateStart = nil;
    NSDate *dateEnd = nil;
    
    NSMutableArray *dates = [[NSMutableArray alloc] init];
    
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    
    
    [comp setDay:comp.day+1];
    [comp setHour:0];
    [comp setMinute:0];

    dateStart = [[NSCalendar currentCalendar] dateFromComponents:comp];

    
    comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    
    [comp setDay:comp.day+1];
    [comp setHour:23];
    [comp setMinute:59];
    
    dateEnd = [[NSCalendar currentCalendar] dateFromComponents:comp];
    
    [dates addObject:dateStart];
    [dates addObject:dateEnd];
        
    return dates;
}

+ (NSDate *)generateDateBeforeDays:(NSInteger)days
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    
    
    [comp setDay:comp.day - days];
    //    [comp setMonth:comp.month];
//    [comp setHour:23];
//    [comp setMinute:59];
    //    [comp setYear:year];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comp];
    
    return date;
}

+(BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
    	return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
    	return NO;
    
    return YES;
}

@end
