// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GLPUser.h instead.

#import <CoreData/CoreData.h>
#import "WebEntity.h"

extern const struct GLPUserAttributes {
	__unsafe_unretained NSString *name;
} GLPUserAttributes;

extern const struct GLPUserRelationships {
	__unsafe_unretained NSString *posts;
} GLPUserRelationships;

extern const struct GLPUserFetchedProperties {
} GLPUserFetchedProperties;

@class Post;



@interface GLPUserID : NSManagedObjectID {}
@end

@interface _GLPUser : WebEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (GLPUserID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Post *posts;

//- (BOOL)validatePosts:(id*)value_ error:(NSError**)error_;





@end

@interface _GLPUser (CoreDataGeneratedAccessors)

@end

@interface _GLPUser (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (Post*)primitivePosts;
- (void)setPrimitivePosts:(Post*)value;


@end
