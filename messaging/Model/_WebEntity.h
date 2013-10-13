// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WebEntity.h instead.

#import <CoreData/CoreData.h>


extern const struct WebEntityAttributes {
	__unsafe_unretained NSString *remoteKey;
} WebEntityAttributes;

extern const struct WebEntityRelationships {
} WebEntityRelationships;

extern const struct WebEntityFetchedProperties {
} WebEntityFetchedProperties;




@interface WebEntityID : NSManagedObjectID {}
@end

@interface _WebEntity : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WebEntityID*)objectID;





@property (nonatomic, strong) NSNumber* remoteKey;



@property int32_t remoteKeyValue;
- (int32_t)remoteKeyValue;
- (void)setRemoteKeyValue:(int32_t)value_;

//- (BOOL)validateRemoteKey:(id*)value_ error:(NSError**)error_;






@end

@interface _WebEntity (CoreDataGeneratedAccessors)

@end

@interface _WebEntity (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveRemoteKey;
- (void)setPrimitiveRemoteKey:(NSNumber*)value;

- (int32_t)primitiveRemoteKeyValue;
- (void)setPrimitiveRemoteKeyValue:(int32_t)value_;




@end
