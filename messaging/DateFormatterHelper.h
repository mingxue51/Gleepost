//
//  DateFormatterHelper.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateFormatterHelper : NSObject

+ (NSDateFormatter *)createDefaultDateFormatter;
+ (NSDateFormatter *)createRemoteDateFormatter;
+ (NSDateFormatter *)createRemoteDateFormatterWithNanoSeconds;
+ (NSDateFormatter *)createTimeDateFormatter;
+ (NSDateFormatter *)createMessageDateFormatter;
+ (NSString *)stringDateServersTypeWithDate:(NSDate *)date;
+ (NSString *)generateStringDateForFSFormat;
+ (NSDate *)generateDateWithDay:(int)day month:(int)month year:(int)year hour:(int)hour andMinutes:(int)minutes;
+ (NSString *)dateUnixFormat:(NSDate *)date;
+(NSDate *)generateDateAfterDays:(int)days;
+(NSDate *)generateDateAfterHours:(int)hours;
+ (NSDate *)generateDateAfterMinutes:(NSInteger)minutes;
+(NSDate *)generateTodayDateWhenItStarts;
+(NSDate *)generateDateWithLastMinutePlusDates:(int)dates;
+(NSArray *)generateTheNextDayStartAndEnd;
+(BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;
+ (NSDate *)generateDateBeforeDays:(NSInteger)days;
+ (NSDate *)addHours:(NSUInteger)hours toDate:(NSDate *)date;

+ (NSString *)generateStringTimeForPostEventWithTime:(NSDate *)date;

@end
