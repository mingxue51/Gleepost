//
//  GLPFacebookConnect.h
//  Gleepost
//
//  Created by Tanmay Khandelwal on 25/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPFacebookConnect : NSObject

+ (void)connectWithFacebook;
+ (BOOL)isFacebookSessionValid;

@end
