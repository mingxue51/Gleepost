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
    [self.fullDateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    return self;
}

@end
