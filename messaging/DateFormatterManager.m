//
//  DateFormatterManager.m
//  messaging
//
//  Created by Lukas on 8/28/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "DateFormatterManager.h"

@implementation DateFormatterManager

@synthesize fullDateFormatter;
@synthesize timeFormatter;

static DateFormatterManager *instance = nil;

+ (DateFormatterManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DateFormatterManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.fullDateFormatter = [[NSDateFormatter alloc] init];
    [self.fullDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateFormat:@"HH:mm"];
    
    return self;
}

+ (NSDateFormatter *)createDefaultDateFormatter
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return f;
}

@end
