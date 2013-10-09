//
//  User.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteEntity.h"
#import "UserNetwork.h"

@interface User : RemoteEntity

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *tagline;
@property (strong, nonatomic) NSString *profileImageUrl;
@property (strong, nonatomic) NSString *course;
@property (strong, nonatomic) UserNetwork *network;

@end
