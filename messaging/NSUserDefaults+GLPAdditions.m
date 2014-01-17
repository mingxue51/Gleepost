//
//  NSUserDefaults+GLPAdditions.m
//  Gleepost
//
//  Created by Tanmay Khandelwal on 26/12/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "NSUserDefaults+GLPAdditions.h"

static NSString * const kGLPAuthParameterEmailKey   = @"kGLPAuthParameterEmailKey";
static NSString * const kGLPAuthParameterNameKey    = @"kGLPAuthParameterNameKey";
static NSString * const kGLPAuthParameterPassKey    = @"kGLPAuthParameterPassKey";

@implementation NSUserDefaults (GLPAdditions)

- (void)saveAuthParameterEmail:(NSString *)email {
    [self setObject:email forKey:kGLPAuthParameterEmailKey];
}

- (NSString *)authParameterEmail {
    return [self objectForKey:kGLPAuthParameterEmailKey];
}

- (void)saveAuthParameterName:(NSString *)name {
    [self setObject:name forKey:kGLPAuthParameterNameKey];
}

- (NSString *)authParameterName {
    return [self objectForKey:kGLPAuthParameterNameKey];
}

- (void)saveAuthParameterPass:(NSString *)pass {
    [self setObject:pass forKey:kGLPAuthParameterPassKey];
}

- (NSString *)authParameterPass {
    return [self objectForKey:kGLPAuthParameterPassKey];
}

@end
