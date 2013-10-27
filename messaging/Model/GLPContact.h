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

@property (strong, nonatomic) GLPUser *user;
@property BOOL youConfirmed;
@property BOOL theyConfirmed;
@end
