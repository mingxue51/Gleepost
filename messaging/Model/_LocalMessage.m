// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to LocalMessage.m instead.

#import "_LocalMessage.h"

const struct LocalMessageAttributes LocalMessageAttributes = {
};

const struct LocalMessageRelationships LocalMessageRelationships = {
	.remoteMessage = @"remoteMessage",
};

const struct LocalMessageFetchedProperties LocalMessageFetchedProperties = {
};

@implementation LocalMessageID
@end

@implementation _LocalMessage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"LocalMessage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"LocalMessage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"LocalMessage" inManagedObjectContext:moc_];
}

- (LocalMessageID*)objectID {
	return (LocalMessageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic remoteMessage;

	






@end
