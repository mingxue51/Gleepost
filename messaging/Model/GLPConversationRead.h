//
//  GLPConversationRead.h
//  Gleepost
//
//  Created by Silouanos on 13/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class has the participant and the last message that participant read.

#import <Foundation/Foundation.h>
#import "GLPUser.h"

@interface GLPConversationRead : NSObject<NSCopying>

@property (strong, nonatomic) GLPUser *participant;
@property (assign, nonatomic) NSInteger messageRemoteKey;

- (id)initWithParticipant:(GLPUser *)participant andMessageRemoteKey:(NSInteger)messageRemoteKey;

@end
