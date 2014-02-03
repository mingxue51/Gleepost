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
static NSString * const kGLPAuthParameterSurnameKey = @"kGLPAuthParameterSurnameKey";


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

- (void)saveAuthParameterSurname:(NSString *)surname {
    [self setObject:surname forKey:kGLPAuthParameterSurnameKey];
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

- (NSString *)authParameterSurname {
    return [self objectForKey:kGLPAuthParameterSurnameKey];
}


@end
