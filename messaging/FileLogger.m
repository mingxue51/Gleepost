//
//  FileLogger.m
//  Gleepost
//
//  Created by Silouanos on 22/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "FileLogger.h"

@implementation FileLogger

+ (FileLogger *)sharedInstance {
    static FileLogger *instance = nil;
    if (instance == nil) instance = [[FileLogger alloc] init];
    return instance;
}

- (id) init
{
    if (self == [super init])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"application.log"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:filePath])
            [fileManager createFileAtPath:filePath
                                 contents:nil
                               attributes:nil];
        logFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [logFile seekToEndOfFile];
    }
    
    return self;
}

- (void)log:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    NSLog(@"%@", message);
    [logFile writeData:[[message stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [logFile synchronizeFile];
    
}

- (void)dealloc {
    logFile = nil;
}

@end
