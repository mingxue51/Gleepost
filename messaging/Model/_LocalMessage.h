// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to LocalMessage.h instead.

#import <CoreData/CoreData.h>


extern const struct LocalMessageAttributes {
} LocalMessageAttributes;

extern const struct LocalMessageRelationships {
	__unsafe_unretained NSString *remoteMessage;
} LocalMessageRelationships;

extern const struct LocalMessageFetchedProperties {
} LocalMessageFetchedProperties;

@class GLPMessage;


@interface LocalMessageID : NSManagedObjectID {}
@end

@interface _LocalMessage : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (LocalMessageID*)objectID;





@property (nonatomic, strong) GLPMessage *remoteMessage;

//- (BOOL)validateRemoteMessage:(id*)value_ error:(NSError**)error_;





@end

@interface _LocalMessage (CoreDataGeneratedAccessors)

@end

@interface _LocalMessage (CoreDataGeneratedPrimitiveAccessors)



- (GLPMessage*)primitiveRemoteMessage;
- (void)setPrimitiveRemoteMessage:(GLPMessage*)value;


@end
