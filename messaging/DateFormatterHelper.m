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
    f.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return f;
}

// date formatter that matches the API format
+ (NSDateFormatter *)createRemoteDateFormatter
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    return f;
}

+ (NSDateFormatter *)createTimeDateFormatter
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.dateFormat = @"HH:mm";
    return f;
}

@end
