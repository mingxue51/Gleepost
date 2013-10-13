// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Conversation.m instead.

#import "_Conversation.h"

const struct ConversationAttributes ConversationAttributes = {
};

const struct ConversationRelationships ConversationRelationships = {
	.messages = @"messages",
	.mostRecentMessage = @"mostRecentMessage",
	.participants = @"participants",
};

const struct ConversationFetchedProperties ConversationFetchedProperties = {
};

@implementation ConversationID
@end

@implementation _Conversation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Conversation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Conversation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Conversation" inManagedObjectContext:moc_];
}

- (ConversationID*)objectID {
	return (ConversationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic messages;

	
- (NSMutableSet*)messagesSet {
	[self willAccessValueForKey:@"messages"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"messages"];
  
	[self didAccessValueForKey:@"messages"];
	return result;
}
	

@dynamic mostRecentMessage;

	

@dynamic participants;

	
- (NSMutableSet*)participantsSet {
	[self willAccessValueForKey:@"participants"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"participants"];
  
	[self didAccessValueForKey:@"participants"];
	return result;
}
	






@end
