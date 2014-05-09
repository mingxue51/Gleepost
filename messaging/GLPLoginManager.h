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

+ (void)loginWithIdentifier:(NSString *)identifier andPassword:(NSString *)password shouldRemember:(BOOL)shouldRemember callback:(void (^)(BOOL success, NSString *errorMessage))callback;
+ (BOOL)performAutoLogin;
+ (void)loginFacebookUserWithName:(NSString *)name withEmail:(NSString *)email response:(NSString *)response callback:(void (^)(BOOL success, NSString *status, NSString *email))callback;
+ (void)logout;
+ (BOOL)isUserRemembered;
+ (BOOL)shouldAutoLogin;

@end
