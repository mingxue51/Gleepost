//
//  GLPDateFormatterHelper.m
//  Gleepost
//
//  Created by Lukas on 2/28/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPDateFormatterHelper.h"

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

@end
