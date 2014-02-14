//
//  NSDate+HumanizedTime.m
//  HumanizedTimeDemo
//
//  Created by Sarp Erdag on 2/29/12.
//  Copyright (c) 2012 Sarp Erdag. All rights reserved.
//

#import "NSDate+HumanizedTime.h"
#import "DateFormatterHelper.h"

#define LOCALISABLE_FULL @"Localizable_full"
#define LOCALISABLE_SHORT @"Localizable"
//#define SUFFIX_UNTIL @"Until the "
#define SUFFIX_UNTIL @""
//#define PREFIX_LEFT @" left"
#define PREFIX_LEFT @"In "
#define PREFIX_AGO  @" ago"

@implementation NSDate (HumanizedTime)

- (NSString *) stringWithHumanizedTimeDifference:(NSDateHumanizedType) humanizedType withFullString:(BOOL) fullStrings
{
    NSTimeInterval timeInterval = [self timeIntervalSinceNow];
    
    int secondsInADay = 3600*24;
    int secondsInAWeek =  3600*24*7;
    int secondsInAMonth =  3600*24*30; //To fix, not precise
    int secondsInAYear = 3600*24*365;
    int yearsDiff = abs(timeInterval/secondsInAYear);
    int monthsDiff = abs(timeInterval/secondsInAMonth);
    int weeksDiff = abs(timeInterval/secondsInAWeek);
    int daysDiff = abs(timeInterval/secondsInADay);
    int hoursDiff = abs((abs(timeInterval) - (daysDiff * secondsInADay)) / 3600);
    int minutesDiff = abs((abs(timeInterval) - ((daysDiff * secondsInADay) + (hoursDiff * 60))) / 60);
    int secondsDiff = abs((abs(timeInterval) - ((daysDiff * secondsInADay) + (minutesDiff * 60))));
  
    NSString *yearString;
    NSString *dateString;
    NSString *weekString;
    NSString *dayString;
    NSString *hourString;
    NSString *minuteString;
    NSString *secondString;
    NSString *full_yearString;
    NSString *full_dateString;
    NSString *full_weekString;
    NSString *full_dayString;
    NSString *full_hourString;
    NSString *full_minuteString;
    NSString *full_secondString;
  
    NSDateFormatter *yearDateFormatter = [[NSDateFormatter alloc] init];
    yearDateFormatter.dateFormat = @"YYYY-MM-dd";
  
    NSDateFormatter *full_yearDateFormatter = [[NSDateFormatter alloc] init];
    full_yearDateFormatter.dateFormat = @"YYYY-MM-dd";
  
    NSDateFormatter *dateDateFormatter = [[NSDateFormatter alloc] init];
    dateDateFormatter.dateFormat = @"dd MMM.";
  
    NSDateFormatter *full_dateDateFormatter = [[NSDateFormatter alloc] init];
    full_dateDateFormatter.dateFormat = @"dd MMMM";

    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat: (fullStrings) ? @"EEEE" : @"EEE"];

    NSString *translation_table = (fullStrings) ? LOCALISABLE_FULL : LOCALISABLE_SHORT;
  
    //NSDateHumanizedSuffixNone
    yearString   = [yearDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]];
    dateString   = [dateDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]];
    weekString   = [NSString stringWithFormat:@"%d%@", weeksDiff, NSLocalizedStringFromTable(@"Week", translation_table, @"")];
    dayString    = [NSString stringWithFormat:@"%d%@", daysDiff, NSLocalizedStringFromTable(@"Day", translation_table, @"")];
    hourString   = [NSString stringWithFormat:@"%d%@", hoursDiff, NSLocalizedStringFromTable(@"Hour", translation_table, @"")];
    minuteString = [NSString stringWithFormat:@"%d%@", minutesDiff, NSLocalizedStringFromTable(@"Minute", translation_table, @"")];
    secondString = [NSString stringWithFormat:@"%d%@", secondsDiff, NSLocalizedStringFromTable(@"Second", translation_table, @"")];
    
    full_yearString   = [full_yearDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]];
    full_dateString   = [full_dateDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]];
    full_weekString   = [NSString stringWithFormat:@"%d %@%@", weeksDiff,
                         NSLocalizedStringFromTable(@"Week", translation_table, @""),
                         (weeksDiff == 1) ? @"" : @""];
    full_dayString    = [NSString stringWithFormat:@"%d %@%@", daysDiff,
                         NSLocalizedStringFromTable(@"Day", translation_table, @""),
                         (daysDiff == 1) ? @"" : @""];
    full_hourString   = [NSString stringWithFormat:@"%d %@%@", hoursDiff,
                         NSLocalizedStringFromTable(@"Hour", translation_table, @""),
                         (hoursDiff == 1) ? @"" : @""];
    full_minuteString = [NSString stringWithFormat:@"%d %@%@", minutesDiff,
                         NSLocalizedStringFromTable(@"Minute", translation_table, @""),
                         (minutesDiff == 1) ? @"" : @""];
    full_secondString = [NSString stringWithFormat:@"%d %@%@", secondsDiff,
                         NSLocalizedStringFromTable(@"Second", translation_table, @""),
                         (secondsDiff == 1) ? @"" : @""];
  
    switch (humanizedType)
    {
      default: break;
      case NSDateHumanizedSuffixLeft:
      {
        if(!fullStrings)
        {
          yearString   = [SUFFIX_UNTIL stringByAppendingString:yearString];
          dateString   = [SUFFIX_UNTIL stringByAppendingString:dateString];
          weekString   = [weekString stringByAppendingString:PREFIX_LEFT];
          dayString    = [dayString stringByAppendingString:PREFIX_LEFT];
          hourString   = [hourString stringByAppendingString:PREFIX_LEFT];
          minuteString = [minuteString stringByAppendingString:PREFIX_LEFT];
          secondString = [secondString stringByAppendingString:PREFIX_LEFT];
        }
        else
        {
//          full_yearString   = [SUFFIX_UNTIL stringByAppendingString:full_yearString];
//          full_dateString   = [SUFFIX_UNTIL stringByAppendingString:full_dateString];
//          full_weekString   = [full_weekString stringByAppendingString:PREFIX_LEFT];
//          full_dayString    = [full_dayString stringByAppendingString:PREFIX_LEFT];
//          full_hourString   = [full_hourString stringByAppendingString:PREFIX_LEFT];
//          full_minuteString = [full_minuteString stringByAppendingString:PREFIX_LEFT];
//          full_secondString = [full_secondString stringByAppendingString:PREFIX_LEFT];
            
            
            full_yearString   = [SUFFIX_UNTIL stringByAppendingString:full_yearString];
//            full_dateString   = [[self getDateName] stringByAppendingFormat:@" @ %@",[self getTime]];
            full_dateString   = [self getMonthWithDate];

//            full_weekString   = [PREFIX_LEFT stringByAppendingString:full_weekString];
            
            full_weekString   = ([self isDateWithinTheWeek])? [[self getDateName] stringByAppendingFormat:@" @ %@",[self getTime]] : [self getMonthWithDate] /*]*/;

//            full_dayString    = [PREFIX_LEFT stringByAppendingString:full_dayString];
            
            full_dayString    = [@"Tomorrow @ " stringByAppendingString:full_dayString];

//            full_hourString   = [PREFIX_LEFT stringByAppendingString:full_hourString];
            full_hourString   = [@"Today @ " stringByAppendingString:[self getTime]];
//            full_minuteString = [PREFIX_LEFT stringByAppendingString:full_minuteString];
            full_minuteString = [@"Today @ " stringByAppendingString:[self getTime]];

//            full_secondString = [PREFIX_LEFT stringByAppendingString:full_secondString];
            full_secondString = [@"Today @ " stringByAppendingString:[self getTime]];

        }
        break;
      }
      case NSDateHumanizedSuffixAgo:
      {
        if(!fullStrings)
        {
          weekString   = [weekString stringByAppendingString:PREFIX_AGO];
          dayString    = [dayString stringByAppendingString:PREFIX_AGO];
          hourString   = [hourString stringByAppendingString:PREFIX_AGO];
          minuteString = [minuteString stringByAppendingString:PREFIX_AGO];
          secondString = [secondString stringByAppendingString:PREFIX_AGO];
        }
        else
        {
          full_weekString   = [full_weekString stringByAppendingString:PREFIX_AGO];
          full_dayString    = [full_dayString stringByAppendingString:PREFIX_AGO];
          full_hourString   = [full_hourString stringByAppendingString:PREFIX_AGO];
          full_minuteString = [full_minuteString stringByAppendingString:PREFIX_AGO];
          full_secondString = [full_secondString stringByAppendingString:PREFIX_AGO];
        }
        break;
      }
    }
  
    if (yearsDiff > 1)
    {
     return (fullStrings)? full_yearString : yearString;
    }
  
    if (monthsDiff > 0)
    {
      return (fullStrings)? full_dateString : dateString;
    }
    else
    {
      if (weeksDiff > 0)
      {
        return (fullStrings)? full_weekString : weekString;
      }
      else
      {
        if (daysDiff > 0 && daysDiff <= 1)
        {
         // return [dayFormatter stringFromDate:self];
            
            return [self getTomorrowWithTime];
        }
        else if (daysDiff > 1)
        {
//          return (fullStrings)? full_dayString : dayString;
            return (fullStrings)? full_weekString : dayString;

        }
        else
        {
          if (hoursDiff == 0)
          {
            if (minutesDiff == 0)
              return (fullStrings)? full_secondString : secondString;
            else
              return (fullStrings)? full_minuteString : minuteString;
          }
          else
          {
              
              NSDate *datePlusOneHour = [DateFormatterHelper generateDateAfterHours:1];
              NSDate *dateLastMinute = [DateFormatterHelper generateDateWithLastMinutePlusDates:0];
              NSArray *nextDayDates = [DateFormatterHelper generateTheNextDayStartAndEnd];

              //Tomorrow or today
              if([DateFormatterHelper date:self isBetweenDate:datePlusOneHour andDate:dateLastMinute])
              {
//                  [_happeningLbl setText:HAPPENING_TODAY_MSG];
                  
                  return [NSString stringWithFormat:@"Today @ %@",[self getTime]];
                  
              }
              else if([DateFormatterHelper date:self isBetweenDate:[nextDayDates objectAtIndex:0] andDate:[nextDayDates objectAtIndex:1]])
              {
//                  [_happeningLbl setText:HAPPENING_TOMORROW_MSG];
                  return [NSString stringWithFormat:@"Tomorrow @ %@",[self getTime]];

              }
              
              return (fullStrings)? full_hourString : hourString;
          }
        }
    }
  }
}

//-(NSString *)getDateName
//{
//    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDate *date = [NSDate date];
//    NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
//    NSInteger todayWeekday = [weekdayComponents weekday];
//    
//    NSInteger moveDays=WEDNESDAY-todayWeekday;
//    if (moveDays<=0) {
//        moveDays+=7;
//    }
//    
//    NSDateComponents *components = [NSDateComponents new];
//    components.day=moveDays;
//    
//    NSCalendar *calendar=[[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
//    NSDate* newDate = [calendar dateByAddingComponents:components toDate:date options:0];
//    
//    NSLog(@"-> %d",moveDays);
//    
//    return newDate;
//}

-(NSString *)getTomorrowWithTime
{
    NSMutableString *tomorrowStr = [[NSMutableString alloc] initWithString:@"Tomorrow"];
    
    [tomorrowStr appendFormat:@" @ %@",[self getTime]];
    
    return tomorrowStr;
}

-(NSString *)getMonthWithDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd"];
    NSMutableString *dateString = [formatter stringFromDate:self].mutableCopy;
    
    NSDateFormatter *suffixFormatter = [[NSDateFormatter alloc] init];
    [suffixFormatter setDateFormat:@"d"];
    
    NSString *suffixDate = [suffixFormatter stringFromDate:self];
    
    
    if([suffixDate hasSuffix:@"1"])
    {
        [dateString appendString:@"st"];
    }
    else if([suffixDate hasSuffix:@"2"])
    {
        [dateString appendString:@"nd"];
    }
    else if([suffixDate hasSuffix:@"3"])
    {
        [dateString appendString:@"rd"];
    }
    else
    {
        [dateString appendString:@"th"];
    }
    
    
    return dateString;
}

-(NSString *)getDateName
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE"];
    NSString *dateString = [formatter stringFromDate:self];
    
    return dateString;
}

-(NSString *)getTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h a"];
    NSString *timeString = [formatter stringFromDate:self];
    
    return timeString;
}

-(BOOL)isDateWithinTheWeek
{
    //Create a new date that will be one week later.
    NSDate *aWeekFromNow = [DateFormatterHelper generateDateAfterDays:7];
    
    
    if([self date:self isBetweenDate:[NSDate date] andDate:aWeekFromNow])
    {
//        DDLogDebug(@"Now %@, Next week %@, Current time %@",[NSDate date], aWeekFromNow, self);

        return YES;
    }
    
    return NO;
}

-(BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
    	return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
    	return NO;
    
    return YES;
}

@end
