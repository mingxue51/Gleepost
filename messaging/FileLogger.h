//
//  FileLogger.h
//  Gleepost
//
//  Created by Silouanos on 22/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileLogger : NSObject
{
    NSFileHandle *logFile;
}

+ (FileLogger *)sharedInstance;
- (void)log:(NSString *)format, ...;


@end

#define FLog(fmt, ...) [[FileLogger sharedInstance] log:fmt, ##__VA_ARGS__]
