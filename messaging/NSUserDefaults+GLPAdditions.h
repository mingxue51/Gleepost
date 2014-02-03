//
//  NSUserDefaults+GLPAdditions.h
//  Gleepost
//
//  Created by Tanmay Khandelwal on 26/12/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (GLPAdditions)

- (void)saveAuthParameterEmail:(NSString *)email;
- (NSString *)authParameterEmail;

- (void)saveAuthParameterName:(NSString *)name;
- (NSString *)authParameterName;

- (void)saveAuthParameterPass:(NSString *)pass;
- (NSString *)authParameterPass;

- (void)saveAuthParameterSurname:(NSString *)surname;
- (NSString *)authParameterSurname;


@end
