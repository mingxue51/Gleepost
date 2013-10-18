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

@end
