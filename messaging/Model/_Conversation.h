// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Conversation.h instead.

#import <CoreData/CoreData.h>
#import "WebEntity.h"

extern const struct ConversationAttributes {
} ConversationAttributes;

extern const struct ConversationRelationships {
	__unsafe_unretained NSString *messages;
	__unsafe_unretained NSString *mostRecentMessage;
	__unsafe_unretained NSString *participants;
} ConversationRelationships;

extern const struct ConversationFetchedProperties {
} ConversationFetchedProperties;

@class GLPMessage;
@class GLPMessage;
@class User;


@interface ConversationID : NSManagedObjectID {}
@end

@interface _Conversation : WebEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ConversationID*)objectID;





@property (nonatomic, strong) NSSet *messages;

- (NSMutableSet*)messagesSet;




@property (nonatomic, strong) GLPMessage *mostRecentMessage;

//- (BOOL)validateMostRecentMessage:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *participants;

- (NSMutableSet*)participantsSet;





@end

@interface _Conversation (CoreDataGeneratedAccessors)

- (void)addMessages:(NSSet*)value_;
- (void)removeMessages:(NSSet*)value_;
- (void)addMessagesObject:(GLPMessage*)value_;
- (void)removeMessagesObject:(GLPMessage*)value_;

- (void)addParticipants:(NSSet*)value_;
- (void)removeParticipants:(NSSet*)value_;
- (void)addParticipantsObject:(User*)value_;
- (void)removeParticipantsObject:(User*)value_;

@end

@interface _Conversation (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableSet*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableSet*)value;



- (GLPMessage*)primitiveMostRecentMessage;
- (void)setPrimitiveMostRecentMessage:(GLPMessage*)value;



- (NSMutableSet*)primitiveParticipants;
- (void)setPrimitiveParticipants:(NSMutableSet*)value;


@end
