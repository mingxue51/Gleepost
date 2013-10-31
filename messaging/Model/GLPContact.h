//
//  GLPContact.h
//  Gleepost
//
//  Created by Σιλουανός on 25/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPEntity.h"
#import "GLPUser.h"



@interface GLPContact : GLPEntity

extern NSString * const GLPContactTheyConfirmed;
extern NSString * const GLPContactYouConfirmed;

@property (strong, nonatomic) GLPUser *user;
@property BOOL youConfirmed;
@property BOOL theyConfirmed;


-(id)initWithUserName:(NSString*)name profileImage:(NSString*)img youConfirmed:(BOOL)you andTheyConfirmed:(BOOL)they;

@end
