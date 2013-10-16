// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Comment.m instead.

#import "_Comment.h"

const struct CommentAttributes CommentAttributes = {
	.content = @"content",
	.date = @"date",
	.dislikes = @"dislikes",
	.likes = @"likes",
};

const struct CommentRelationships CommentRelationships = {
	.author = @"author",
	.post = @"post",
};

const struct CommentFetchedProperties CommentFetchedProperties = {
};

@implementation CommentID
@end

@implementation _Comment

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Comment";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:moc_];
}

- (CommentID*)objectID {
	return (CommentID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"dislikesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"dislikes"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"likesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"likes"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic content;






@dynamic date;






@dynamic dislikes;



- (int32_t)dislikesValue {
	NSNumber *result = [self dislikes];
	return [result intValue];
}

- (void)setDislikesValue:(int32_t)value_ {
	[self setDislikes:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveDislikesValue {
	NSNumber *result = [self primitiveDislikes];
	return [result intValue];
}

- (void)setPrimitiveDislikesValue:(int32_t)value_ {
	[self setPrimitiveDislikes:[NSNumber numberWithInt:value_]];
}





@dynamic likes;



- (int32_t)likesValue {
	NSNumber *result = [self likes];
	return [result intValue];
}

- (void)setLikesValue:(int32_t)value_ {
	[self setLikes:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveLikesValue {
	NSNumber *result = [self primitiveLikes];
	return [result intValue];
}

- (void)setPrimitiveLikesValue:(int32_t)value_ {
	[self setPrimitiveLikes:[NSNumber numberWithInt:value_]];
}





@dynamic author;

	

@dynamic post;

	






@end
