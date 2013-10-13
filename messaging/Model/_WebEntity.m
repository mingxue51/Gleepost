// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WebEntity.m instead.

#import "_WebEntity.h"

const struct WebEntityAttributes WebEntityAttributes = {
	.remoteKey = @"remoteKey",
};

const struct WebEntityRelationships WebEntityRelationships = {
};

const struct WebEntityFetchedProperties WebEntityFetchedProperties = {
};

@implementation WebEntityID
@end

@implementation _WebEntity

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WebEntity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WebEntity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WebEntity" inManagedObjectContext:moc_];
}

- (WebEntityID*)objectID {
	return (WebEntityID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"remoteKeyValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"remoteKey"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic remoteKey;



- (int32_t)remoteKeyValue {
	NSNumber *result = [self remoteKey];
	return [result intValue];
}

- (void)setRemoteKeyValue:(int32_t)value_ {
	[self setRemoteKey:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveRemoteKeyValue {
	NSNumber *result = [self primitiveRemoteKey];
	return [result intValue];
}

- (void)setPrimitiveRemoteKeyValue:(int32_t)value_ {
	[self setPrimitiveRemoteKey:[NSNumber numberWithInt:value_]];
}










@end
