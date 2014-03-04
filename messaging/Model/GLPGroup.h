//
//  GLGroup.h
//  Gleepost
//
//  Created by Σιλουανός on 3/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPEntity.h"

@interface GLPGroup : GLPEntity

@property (strong, nonatomic) NSString *name;

-(id)initWithName:(NSString *)name andRemoteKey:(int)remoteKey;

@end
