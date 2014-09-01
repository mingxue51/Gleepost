//
//  NSString+Utils.h
//  messaging
//
//  Created by Lukas on 8/28/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

- (BOOL)isEmpty;
+ (BOOL)isStringEmpty:(NSString *)string;

- (BOOL)isNotEmpty;
- (BOOL)isNotBlank;

- (BOOL)exceedsNumberOfCharacters:(NSInteger)noOfCharacters;

@end