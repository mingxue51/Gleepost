//
//  NSDate+Calculations.m
//  Gleepost
//
//  Created by Silouanos on 20/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "NSDate+Calculations.h"

@implementation NSDate (Calculations)

- (NSString *)substractWithDate:(NSDate *)date
{
    NSTimeInterval diff = [self timeIntervalSinceDate:date];
    
    DDLogDebug(@"Diff %f", diff);
    
//    NSInteger minutes = (diff / 60) % 60;
    NSInteger hours = (diff / 3600);
    
    return [NSString stringWithFormat:@"%ld h", (long)hours];
}

@end
