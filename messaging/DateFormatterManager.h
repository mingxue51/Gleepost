//
//  DateFormatterManager.h
//  messaging
//
//  Created by Lukas on 8/28/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateFormatterManager : NSObject

@property (strong, nonatomic) NSDateFormatter *fullDateFormatter;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;

+ (DateFormatterManager *)sharedInstance;

@end
