//
//  GLPCategory.h
//  Gleepost
//
//  Created by Silouanos on 21/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPEntity.h"

@interface GLPCategory : GLPEntity

@property (assign, nonatomic) int postRemoteKey;
@property (strong, nonatomic) NSString *tag;
@property (strong, nonatomic) NSString *name;

-(id)initWithTag:(NSString*)tag name:(NSString*)name andPostRemoteKey:(int)postRemoteKey;
-(id)initWithTag:(NSString*)tag name:(NSString*)name postRemoteKey:(int)postRemoteKey andRemoteKey:(int)remoteKey;

@end
