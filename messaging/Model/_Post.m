// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Post.m instead.

#import "_Post.h"

const struct PostAttributes PostAttributes = {
	.commentsCount = @"commentsCount",
	.content = @"content",
	.date = @"date",
	.dislikes = @"dislikes",
	.imagesUrls = @"imagesUrls",
	.likes = @"likes",
};

const struct PostRelationships PostRelationships = {
	.author = @"author",
	.comments = @"comments",
};

const struct PostFetchedProperties PostFetchedProperties = {
};

@implementation PostID
@end

@implementation _Post

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Post";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Post" inManagedObjectContext:moc_];
}

- (PostID*)objectID {
	return (PostID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"commentsCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"commentsCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
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




@dynamic commentsCount;



- (int32_t)commentsCountValue {
	NSNumber *result = [self commentsCount];
	return [result intValue];
}

- (void)setCommentsCountValue:(int32_t)value_ {
	[self setCommentsCount:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveCommentsCountValue {
	NSNumber *result = [self primitiveCommentsCount];
	return [result intValue];
}

- (void)setPrimitiveCommentsCountValue:(int32_t)value_ {
	[self setPrimitiveCommentsCount:[NSNumber numberWithInt:value_]];
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





@dynamic imagesUrls;






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

	

@dynamic comments;

	
- (NSMutableSet*)commentsSet {
	[self willAccessValueForKey:@"comments"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"comments"];
  
	[self didAccessValueForKey:@"comments"];
	return result;
}
	






@end
