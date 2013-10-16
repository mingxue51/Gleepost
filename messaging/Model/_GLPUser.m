// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GLPUser.m instead.

#import "_GLPUser.h"

const struct GLPUserAttributes GLPUserAttributes = {
	.name = @"name",
};

const struct GLPUserRelationships GLPUserRelationships = {
	.posts = @"posts",
};

const struct GLPUserFetchedProperties GLPUserFetchedProperties = {
};

@implementation GLPUserID
@end

@implementation _GLPUser

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"GLPUser" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"GLPUser";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"GLPUser" inManagedObjectContext:moc_];
}

- (GLPUserID*)objectID {
	return (GLPUserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic posts;

	






@end
