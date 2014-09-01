//
//  NSString+Utils.m
//  messaging
//
//  Created by Lukas on 8/28/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (BOOL)isEmpty
{
    return [NSString isStringEmpty:self];
}

+ (BOOL)isStringEmpty:(NSString *)string
{
    if([string length] == 0) {
        return YES;
    }
    
    if(![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isNotEmpty
{
    return [self length] != 0;
}

- (BOOL)isNotBlank
{
    if (![self isNotEmpty]) {
        return NO;
    }

    NSCharacterSet *nonWhitespaceSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
    NSRange range = [self rangeOfCharacterFromSet:nonWhitespaceSet];
    
    return range.location != NSNotFound;
}

- (BOOL)exceedsNumberOfCharacters:(NSInteger)noOfCharacters
{
    return self.length > noOfCharacters;
}

@end
