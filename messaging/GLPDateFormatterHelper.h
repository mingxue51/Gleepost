//
//  GLPDateFormatterHelper.h
//  Gleepost
//
//  Created by Lukas on 2/28/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPDateFormatterHelper : NSObject

+ (NSDateFormatter *)messageDateFormatter;
+ (NSDateFormatter *)messageDateFormatterWithDate:(NSDate *)messageDate;

@end
