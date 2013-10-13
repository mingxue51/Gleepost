// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Message.h instead.

#import <CoreData/CoreData.h>
#import "WebEntity.h"

extern const struct MessageAttributes {
	__unsafe_unretained NSString *content;
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *seen;
	__unsafe_unretained NSString *sendStatus;
} MessageAttributes;

extern const struct MessageRelationships {
	__unsafe_unretained NSString *author;
	__unsafe_unretained NSString *conversation;
} MessageRelationships;

extern const struct MessageFetchedProperties {
} MessageFetchedProperties;

@class User;
@class Conversation;






@interface MessageID : NSManagedObjectID {}
@end

@interface _Message : WebEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MessageID*)objectID;





@property (nonatomic, strong) NSString* content;



//- (BOOL)validateContent:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* date;



//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* seen;



@property BOOL seenValue;
- (BOOL)seenValue;
- (void)setSeenValue:(BOOL)value_;

//- (BOOL)validateSeen:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sendStatus;



@property int32_t sendStatusValue;
- (int32_t)sendStatusValue;
- (void)setSendStatusValue:(int32_t)value_;

//- (BOOL)validateSendStatus:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) User *author;

//- (BOOL)validateAuthor:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) Conversation *conversation;

//- (BOOL)validateConversation:(id*)value_ error:(NSError**)error_;





@end

@interface _Message (CoreDataGeneratedAccessors)

@end

@interface _Message (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveContent;
- (void)setPrimitiveContent:(NSString*)value;




- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (NSNumber*)primitiveSeen;
- (void)setPrimitiveSeen:(NSNumber*)value;

- (BOOL)primitiveSeenValue;
- (void)setPrimitiveSeenValue:(BOOL)value_;




- (NSNumber*)primitiveSendStatus;
- (void)setPrimitiveSendStatus:(NSNumber*)value;

- (int32_t)primitiveSendStatusValue;
- (void)setPrimitiveSendStatusValue:(int32_t)value_;





- (User*)primitiveAuthor;
- (void)setPrimitiveAuthor:(User*)value;



- (Conversation*)primitiveConversation;
- (void)setPrimitiveConversation:(Conversation*)value;


@end
