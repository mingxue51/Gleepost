//
//  GLPLiveConversation.h
//  Gleepost
//
//  Created by Σιλουανός on 28/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPEntity.h"
#import "GLPUser.h"
#import "GLPConversation.h"

@interface GLPLiveConversation : GLPEntity

-(id)initWithConversation:(GLPConversation*)conversation;

@property (strong, nonatomic) NSDate *timeStarted;
@property (strong, nonatomic) NSDate *lastUpdate;
@property (strong, nonatomic) GLPUser *author;
@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) NSArray *participants;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL hasUnreadMessages;
@property (assign, nonatomic) BOOL isLiveConversation;
@property (assign, nonatomic) NSDate *expiry;

- (void)setTitleFromParticipants:(NSArray *)participants;

@end
