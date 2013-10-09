//
//  User.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteEntity.h"

@interface User : RemoteEntity

@property (strong, nonatomic) NSString *name;

@end
