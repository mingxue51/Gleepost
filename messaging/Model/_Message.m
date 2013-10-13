// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Message.m instead.

#import "_Message.h"

const struct MessageAttributes MessageAttributes = {
	.content = @"content",
	.date = @"date",
	.seen = @"seen",
	.sendStatus = @"sendStatus",
};

const struct MessageRelationships MessageRelationships = {
	.author = @"author",
	.conversation = @"conversation",
};

const struct MessageFetchedProperties MessageFetchedProperties = {
};

@implementation MessageID
@end

@implementation _Message

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Message";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Message" inManagedObjectContext:moc_];
}

- (MessageID*)objectID {
	return (MessageID*)[super objectID];
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
