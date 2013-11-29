//
//  LoginManager.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPUser.h"

@interface GLPLoginManager : NSObject

+ (void)loginWithIdentifier:(NSString *)identifier andPassword:(NSString *)password callback:(void (^)(BOOL success))callback;
+ (void)loginFacebookUserWithName:(NSString *)name response:(NSString *)response callback:(void (^)(BOOL success))callback;
+ (void)logout;

@end
