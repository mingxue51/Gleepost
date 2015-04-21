//
//  NSDate+Calculations.m
//  Gleepost
//
//  Created by Silouanos on 20/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "NSDate+Calculations.h"

@implementation NSDate (Calculations)

/**
 This method calculates the distance between 2 dates and returns a suitable 
 string that represents the time or minutes left depending on how far away 
 is the receiving date from the current date.
 
 */
- (NSString *)substractWithDate:(NSDate *)date
{
    NSTimeInterval diff = [self timeIntervalSinceDate:date];
    
    if(diff < 0)
    {
        return @"ENDED";
    }
    
    NSInteger minutes = (NSInteger)(diff / 60.0) % 60;
    NSInteger hours = (diff / 3600);
    
    if(hours == 0)
    {
        return [NSString stringWithFormat:@"%ld m", (long)minutes];
    }
    
    return [NSString stringWithFormat:@"%ld h", (long)hours];
}

@end
