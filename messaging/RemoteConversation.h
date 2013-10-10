//
//  RemoteConversation.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RemoteMessage, RemoteUser;

@interface RemoteConversation : NSManagedObject

@property (nonatomic, retain) NSNumber * remoteKey;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *participants;
@property (nonatomic, retain) RemoteMessage *mostRecentMessage;
@end

@interface RemoteConversation (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(RemoteMessage *)value;
- (void)removeMessagesObject:(RemoteMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addParticipantsObject:(RemoteUser *)value;
- (void)removeParticipantsObject:(RemoteUser *)value;
- (void)addParticipants:(NSSet *)values;
- (void)removeParticipants:(NSSet *)values;

@end
