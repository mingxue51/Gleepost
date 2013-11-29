//
//  NSNotificationCenter+Utils.h
//  Gleepost
//
//  Created by Lukas on 11/24/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (Utils)

- (void)postNotificationOnMainThread:(NSNotification *)notification;
- (void)postNotificationNameOnMainThread:(NSString *)name object:(id)object;
- (void)postNotificationNameOnMainThread:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;

@end
