// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>
#import "WebEntity.h"

extern const struct UserAttributes {
	__unsafe_unretained NSString *name;
} UserAttributes;

extern const struct UserRelationships {
	__unsafe_unretained NSString *posts;
} UserRelationships;

extern const struct UserFetchedProperties {
} UserFetchedProperties;

@class Post;



@interface UserID : NSManagedObjectID {}
@end

@interface _User : WebEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UserID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Post *posts;

//- (BOOL)validatePosts:(id*)value_ error:(NSError**)error_;





@end

@interface _User (CoreDataGeneratedAccessors)

@end

@interface _User (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (Post*)primitivePosts;
- (void)setPrimitivePosts:(Post*)value;


@end
