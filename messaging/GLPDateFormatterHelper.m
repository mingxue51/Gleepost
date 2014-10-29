//
//  GLPDateFormatterHelper.m
//  Gleepost
//
//  Created by Lukas on 2/28/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPDateFormatterHelper.h"
#import "DateFormatterHelper.h"

@implementation GLPDateFormatterHelper

+ (NSDateFormatter *)messageDateFormatter
{
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary] ;
    NSDateFormatter *dateFormatter = [threadDictionary objectForKey: @"GLPMessageDateFormatter"] ;
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"EEEE hh:mm a";
        
        [threadDictionary setObject: dateFormatter forKey: @"DDMyDateFormatter"] ;
    }
    
    return dateFormatter;
}

+ (NSDateFormatter *)messageDateFormatterWithDate:(NSDate *)messageDate
{
    NSDate *now = [NSDate date];
    NSDate *yesterday = [DateFormatterHelper generateDateBeforeDays:1];
    NSDate *weekAgo = [DateFormatterHelper generateDateBeforeDays:7];
    NSDate *yearAgo = [DateFormatterHelper generateDateBeforeDays:365];
    
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary] ;
    NSDateFormatter *dateFormatter = [threadDictionary objectForKey: @"GLPMessageDateFormatter"] ;
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        if([DateFormatterHelper date:messageDate isBetweenDate:yesterday andDate:now])
        {
            dateFormatter.dateFormat = @"hh:mm a";
        }
        else if([DateFormatterHelper date:messageDate isBetweenDate:weekAgo andDate:yesterday])
        {
            dateFormatter.dateFormat = @"EEEE hh:mm a";
        }
        else if ([DateFormatterHelper date:messageDate isBetweenDate:yearAgo andDate:weekAgo])
        {
            dateFormatter.dateFormat = @"MMMM d hh:mm a";
        }
        else
        {
            dateFormatter.dateFormat = @"MM/d/yyyy hh:mm a";
        }
        
        [threadDictionary setObject: dateFormatter forKey: @"DDMyDateFormatter"] ;
    }
    
    return dateFormatter;
}

@end
