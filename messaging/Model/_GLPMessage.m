// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GLPMessage.m instead.

#import "_GLPMessage.h"

const struct GLPMessageAttributes GLPMessageAttributes = {
	.content = @"content",
	.date = @"date",
	.seen = @"seen",
	.sendStatus = @"sendStatus",
};

const struct GLPMessageRelationships GLPMessageRelationships = {
	.author = @"author",
	.conversation = @"conversation",
};

const struct GLPMessageFetchedProperties GLPMessageFetchedProperties = {
};

@implementation GLPMessageID
@end

@implementation _GLPMessage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"GLPMessage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"GLPMessage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"GLPMessage" inManagedObjectContext:moc_];
}

- (GLPMessageID*)objectID {
	return (GLPMessageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"seenValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"seen"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sendStatusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sendStatus"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic content;






@dynamic date;






@dynamic seen;



- (BOOL)seenValue {
	NSNumber *result = [self seen];
	return [result boolValue];
}

- (void)setSeenValue:(BOOL)value_ {
	[self setSeen:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveSeenValue {
	NSNumber *result = [self primitiveSeen];
	return [result boolValue];
}

- (void)setPrimitiveSeenValue:(BOOL)value_ {
	[self setPrimitiveSeen:[NSNumber numberWithBool:value_]];
}





@dynamic sendStatus;



- (int32_t)sendStatusValue {
	NSNumber *result = [self sendStatus];
	return [result intValue];
}

- (void)setSendStatusValue:(int32_t)value_ {
	[self setSendStatus:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveSendStatusValue {
	NSNumber *result = [self primitiveSendStatus];
	return [result intValue];
}

- (void)setPrimitiveSendStatusValue:(int32_t)value_ {
	[self setPrimitiveSendStatus:[NSNumber numberWithInt:value_]];
}





@dynamic author;

	

@dynamic conversation;

	






@end
